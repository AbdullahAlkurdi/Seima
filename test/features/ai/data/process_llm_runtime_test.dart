import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/ai/data/llm_runtime.dart';
import 'package:mindora/features/ai/data/process_llm_runtime.dart';

void main() {
  group('ProcessLLMRuntime', () {
    late ProcessLLMRuntime runtime;

    setUp(() {
      runtime = ProcessLLMRuntime();
    });

    tearDown(() async {
      await runtime.dispose();
    });

    test('initial status is unavailable', () async {
      expect(await runtime.status, ModelStatus.unavailable);
    });

    test('initialize fails gracefully with non-existent model', () async {
      await runtime.initialize(modelPath: '/nonexistent/model.gguf');
      expect(await runtime.status, ModelStatus.unavailable);
    });

    test('modelInfo returns default when not initialized', () async {
      final info = await runtime.modelInfo;
      expect(info.modelName, 'No model loaded');
      expect(info.isLoaded, false);
    });

    test('unloadModel returns to notInitialized', () async {
      await runtime.unloadModel();
      expect(await runtime.status, ModelStatus.notInitialized);
    });

    test('dispose transitions to notInitialized', () async {
      await runtime.dispose();
      expect(await runtime.status, ModelStatus.notInitialized);
    });

    test('generate emits error on stream when not initialized', () async {
      final stream = runtime.generate('test prompt');
      expect(stream, emitsError(isA<StateError>()));
    });

    test('is a LocalLLMRuntime', () {
      expect(runtime, isA<LocalLLMRuntime>());
    });

    test('reinitialize after unload', () async {
      await runtime.unloadModel();
      expect(await runtime.status, ModelStatus.notInitialized);
      await runtime.initialize(modelPath: '/test/model.gguf');
      expect(await runtime.status, ModelStatus.unavailable);
    });

    test('generate throws StateError when already generating', () {
      runtime.generate('first prompt');
      expect(() => runtime.generate('second prompt'), throwsStateError);
    });

    test('generate does not throw after first stream completes', () async {
      runtime.generate('first prompt');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        () => runtime.generate('after completed'),
        isNot(throwsStateError),
      );
    });
  });
}
