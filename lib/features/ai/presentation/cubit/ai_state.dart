import 'package:mindora/features/ai/domain/ai_config.dart';
import 'package:mindora/features/ai/domain/ai_failure.dart';
import 'package:mindora/features/ai/domain/ai_proposal.dart';

enum AIStatus { initial, loading, streaming, success, failure }

enum ModelState { unknown, notAvailable, downloading, ready, error }

class AIState {
  final AIStatus status;
  final String? analysisText;
  final List<AIProposal> proposals;
  final AIFailure? failure;
  final AIConfig config;
  final bool isPanelOpen;

  final ModelState modelState;
  final double? downloadProgress;

  const AIState({
    this.status = AIStatus.initial,
    this.analysisText,
    this.proposals = const [],
    this.failure,
    this.config = const AIConfig(),
    this.isPanelOpen = false,
    this.modelState = ModelState.unknown,
    this.downloadProgress,
  });

  bool get hasAnalysis => analysisText != null && analysisText!.isNotEmpty;
  bool get hasProposals => proposals.isNotEmpty;
  bool get isLoading => status == AIStatus.loading;
  bool get isStreaming => status == AIStatus.streaming;
  bool get hasError => status == AIStatus.failure;
  bool get isModelReady => modelState == ModelState.ready;
  bool get isModelDownloading => modelState == ModelState.downloading;

  AIState copyWith({
    AIStatus? status,
    String? analysisText,
    bool clearAnalysis = false,
    List<AIProposal>? proposals,
    AIFailure? failure,
    bool clearError = false,
    AIConfig? config,
    bool? isPanelOpen,
    ModelState? modelState,
    double? downloadProgress,
    bool clearDownloadProgress = false,
  }) {
    return AIState(
      status: status ?? this.status,
      analysisText: clearAnalysis ? null : analysisText ?? this.analysisText,
      proposals: proposals ?? this.proposals,
      failure: clearError ? null : failure ?? this.failure,
      config: config ?? this.config,
      isPanelOpen: isPanelOpen ?? this.isPanelOpen,
      modelState: modelState ?? this.modelState,
      downloadProgress: clearDownloadProgress
          ? null
          : downloadProgress ?? this.downloadProgress,
    );
  }
}
