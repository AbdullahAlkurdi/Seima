import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindora/features/ai/data/ai_service.dart';
import 'package:mindora/features/ai/data/llm_runtime.dart';
import 'package:mindora/features/ai/data/model_manager.dart';
import 'package:mindora/features/ai/data/mind_context_builder.dart';
import 'package:mindora/features/ai/domain/ai_config.dart';
import 'package:mindora/features/ai/domain/ai_context.dart';
import 'package:mindora/features/ai/domain/ai_failure.dart';
import 'package:mindora/features/ai/presentation/cubit/ai_state.dart';

class AICubit extends Cubit<AIState> {
  final AIService aiService;
  final LocalLLMRuntime? llmRuntime;
  final ModelManager? modelManager;
  final MindContextBuilder contextBuilder;
  AIContext? _currentContext;
  StreamSubscription<String>? _streamSubscription;
  bool _isAnalyzing = false;

  AICubit({
    required this.aiService,
    this.llmRuntime,
    this.modelManager,
    MindContextBuilder? contextBuilder,
  }) : contextBuilder = contextBuilder ?? const MindContextBuilder(),
       super(const AIState());

  void setContext(AIContext context) {
    _currentContext = context;
  }

  void openPanel() {
    emit(state.copyWith(isPanelOpen: true));
    _checkModelStatus();
  }

  void closePanel() {
    _cancelStreaming();
    emit(state.copyWith(isPanelOpen: false));
  }

  @override
  Future<void> close() {
    _cancelStreaming();
    return super.close();
  }

  Future<void> _checkModelStatus() async {
    if (modelManager == null || llmRuntime == null) {
      emit(state.copyWith(modelState: ModelState.notAvailable));
      return;
    }

    final runtimeStatus = await llmRuntime!.status;
    if (runtimeStatus == ModelStatus.ready) {
      emit(state.copyWith(modelState: ModelState.ready));
      return;
    }

    final hasModel = await modelManager!.isModelDownloaded();
    if (hasModel) {
      final modelPath = await modelManager!.getModelPath();
      if (modelPath != null) {
        await llmRuntime!.initialize(modelPath: modelPath);
        final status = await llmRuntime!.status;
        emit(
          state.copyWith(
            modelState: status == ModelStatus.ready
                ? ModelState.ready
                : ModelState.notAvailable,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(modelState: ModelState.notAvailable));
  }

  Future<void> downloadModel() async {
    if (modelManager == null) {
      emit(
        state.copyWith(
          modelState: ModelState.error,
          failure: AIFailure.model('Model download manager not available.'),
        ),
      );
      return;
    }

    emit(
      state.copyWith(modelState: ModelState.downloading, downloadProgress: 0.0),
    );

    try {
      final modelPath = await modelManager!.downloadModel(
        onProgress: (progress) {
          emit(state.copyWith(downloadProgress: progress));
        },
      );

      if (llmRuntime != null) {
        await llmRuntime!.initialize(modelPath: modelPath);
        final status = await llmRuntime!.status;
        if (status == ModelStatus.ready) {
          emit(
            state.copyWith(
              modelState: ModelState.ready,
              clearDownloadProgress: true,
              config: const AIConfig(useLLM: true),
            ),
          );
          return;
        }
      }

      emit(
        state.copyWith(
          modelState: ModelState.error,
          failure: AIFailure.model('Model downloaded but failed to load.'),
          clearDownloadProgress: true,
        ),
      );
    } on AIFailure {
      emit(
        state.copyWith(
          modelState: ModelState.error,
          clearDownloadProgress: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          modelState: ModelState.error,
          failure: AIFailure.unknown('Failed to download model: $e'),
          clearDownloadProgress: true,
        ),
      );
    }
  }

  Future<void> analyze() async {
    if (_currentContext == null) return;
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    emit(
      state.copyWith(
        status: AIStatus.loading,
        clearAnalysis: true,
        clearError: true,
        proposals: [],
      ),
    );

    try {
      final response = await aiService.analyze(
        context: _currentContext!,
        config: const AIConfig(),
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AIStatus.success,
            analysisText: response.analysisText,
            proposals: response.proposals,
          ),
        );
      }
    } on AIFailure catch (e) {
      if (!isClosed) {
        emit(state.copyWith(status: AIStatus.failure, failure: e));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AIStatus.failure,
            failure: AIFailure.unknown('An unexpected error occurred.'),
          ),
        );
      }
    } finally {
      _isAnalyzing = false;
    }
  }

  void analyzeStreaming() {
    if (_currentContext == null) return;
    if (_isAnalyzing) return;

    _isAnalyzing = true;
    _cancelStreaming();

    emit(
      state.copyWith(
        status: AIStatus.loading,
        clearAnalysis: true,
        clearError: true,
        proposals: [],
      ),
    );

    final isLLM = state.isModelReady && llmRuntime != null;

    if (isLLM) {
      _startLLMStreaming();
    } else {
      analyze();
    }
  }

  void _startLLMStreaming() {
    if (_currentContext == null) return;

    emit(state.copyWith(status: AIStatus.streaming, analysisText: ''));

    _streamSubscription = aiService
        .analyzeStreaming(context: _currentContext!, config: const AIConfig())
        .listen(
          (token) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: AIStatus.streaming,
                  analysisText: '${state.analysisText ?? ''}$token',
                ),
              );
            }
          },
          onError: (error) {
            _isAnalyzing = false;
            if (!isClosed) {
              emit(
                state.copyWith(
                  status: AIStatus.failure,
                  failure: AIFailure.unknown('Streaming error: $error'),
                ),
              );
            }
          },
          onDone: () {
            _isAnalyzing = false;
            if (!isClosed) {
              emit(state.copyWith(status: AIStatus.success));
            }
          },
        );
  }

  void _cancelStreaming() {
    _isAnalyzing = false;
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void retry() {
    if (_currentContext != null) {
      analyze();
    }
  }

  void clearAnalysis() {
    _cancelStreaming();
    emit(
      state.copyWith(
        status: AIStatus.initial,
        clearAnalysis: true,
        proposals: [],
        clearError: true,
      ),
    );
  }
}
