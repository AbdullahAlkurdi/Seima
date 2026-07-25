import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'llm_runtime.dart';
import 'model_info.dart';

class ProcessLLMRuntime implements LocalLLMRuntime {
  Process? _process;
  String? _modelPath;
  String? _executablePath;
  ModelStatus _status = ModelStatus.unavailable;
  ModelInfo _modelInfo = const ModelInfo(
    modelName: 'No model loaded',
    modelPath: '',
    modelSizeBytes: 0,
    isLoaded: false,
  );
  bool _isGenerating = false;
  StreamController<String>? _activeController;

  static const _generationTimeout = Duration(seconds: 120);

  @override
  Future<ModelStatus> get status async => _status;

  @override
  Future<ModelInfo> get modelInfo async => _modelInfo;

  @override
  Future<void> initialize({
    required String modelPath,
    String? executablePath,
  }) async {
    _status = ModelStatus.initializing;
    _modelPath = modelPath;
    _executablePath = executablePath ?? _findDefaultExecutable();

    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      _status = ModelStatus.unavailable;
      _modelInfo = const ModelInfo(
        modelName: 'Model file not found',
        modelPath: '',
        modelSizeBytes: 0,
        isLoaded: false,
      );
      return;
    }

    final execFile = _executablePath != null ? File(_executablePath!) : null;
    if (execFile != null && !await execFile.exists()) {
      _status = ModelStatus.unavailable;
      _modelInfo = ModelInfo(
        modelName: 'Runtime executable not found',
        modelPath: modelPath,
        modelSizeBytes: 0,
        isLoaded: false,
      );
      return;
    }

    final modelStat = await modelFile.stat();
    _modelInfo = ModelInfo(
      modelName: _extractModelName(modelPath),
      modelPath: modelPath,
      modelSizeBytes: modelStat.size,
      isLoaded: true,
      runtimeVersion: _executablePath ?? 'llama-cli',
    );
    _status = ModelStatus.ready;
  }

  String _findDefaultExecutable() {
    if (Platform.isWindows) return 'llama-cli.exe';
    return 'llama-cli';
  }

  String _extractModelName(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    return name.replaceAll(RegExp(r'\.gguf$'), '');
  }

  @override
  Future<void> unloadModel() async {
    await _cancelGeneration();
    await _killProcess();
    _status = ModelStatus.notInitialized;
    _modelInfo = const ModelInfo(
      modelName: 'No model loaded',
      modelPath: '',
      modelSizeBytes: 0,
      isLoaded: false,
    );
  }

  @override
  Stream<String> generate(String prompt) {
    if (_isGenerating) {
      throw StateError('LLM generation already in progress');
    }
    _isGenerating = true;

    final controller = StreamController<String>();
    _activeController = controller;

    _runInference(prompt, controller)
        .then((_) {
          _isGenerating = false;
          _activeController = null;
          if (!controller.isClosed) controller.close();
        })
        .catchError((error) {
          _isGenerating = false;
          _activeController = null;
          if (!controller.isClosed) {
            controller.addError(error);
            controller.close();
          }
        });

    return controller.stream;
  }

  Future<void> _runInference(
    String prompt,
    StreamController<String> controller,
  ) async {
    if (_executablePath == null || _modelPath == null) {
      throw StateError('LLM runtime not initialized');
    }

    try {
      _process = await Process.start(_executablePath!, [
        '-m',
        _modelPath!,
        '--prompt',
        prompt,
        '--no-display-prompt',
        '--temp',
        '0.7',
        '--ctx-size',
        '4096',
        '--predict',
        '-1',
      ], runInShell: true);
    } catch (e) {
      _status = ModelStatus.error;
      rethrow;
    }

    _status = ModelStatus.ready;

    final lineStream = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    try {
      await for (final line in lineStream) {
        if (controller.isClosed) break;
        if (line.trim().isNotEmpty) {
          controller.add(line);
        }
      }
    } catch (_) {
      if (!controller.isClosed) rethrow;
    }

    if (!controller.isClosed) {
      await _process!.exitCode.timeout(
        _generationTimeout,
        onTimeout: () {
          _killProcess();
          return -1;
        },
      );
    }
  }

  Future<void> _cancelGeneration() async {
    _isGenerating = false;
    final controller = _activeController;
    _activeController = null;
    if (controller != null && !controller.isClosed) {
      try {
        await controller.close();
      } catch (_) {}
    }
    await _killProcess();
  }

  Future<void> _killProcess() async {
    try {
      _process?.kill();
      await _process?.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () => -1,
      );
    } catch (_) {}
    _process = null;
    _status = ModelStatus.notInitialized;
  }

  @override
  Future<void> dispose() async {
    await _cancelGeneration();
  }
}
