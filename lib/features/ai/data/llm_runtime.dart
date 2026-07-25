import 'dart:async';
import 'model_info.dart';

abstract class LocalLLMRuntime {
  Future<ModelStatus> get status;

  Future<ModelInfo> get modelInfo;

  Future<void> initialize({required String modelPath, String? executablePath});

  Future<void> unloadModel();

  Stream<String> generate(String prompt);

  Future<void> dispose();
}

enum ModelStatus { unavailable, notInitialized, initializing, ready, error }
