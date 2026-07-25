import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/ai/data/ai_service.dart';
import 'package:seima/features/ai/data/llm_ai_service.dart';
import 'package:seima/features/ai/data/llm_runtime.dart';
import 'package:seima/features/ai/data/model_info.dart';
import 'package:seima/features/ai/domain/ai_config.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/ai/domain/ai_response.dart';

class _MockLLMRuntime implements LocalLLMRuntime {
  ModelStatus _status = ModelStatus.ready;

  _MockLLMRuntime();

  void setStatus(ModelStatus status) => _status = status;

  @override
  Future<ModelStatus> get status async => _status;

  @override
  Future<ModelInfo> get modelInfo async => ModelInfo(
    modelName: 'test-model',
    modelPath: '/test/model.gguf',
    modelSizeBytes: 1000,
    isLoaded: true,
  );

  @override
  Future<void> initialize({
    required String modelPath,
    String? executablePath,
  }) async {}

  @override
  Future<void> unloadModel() async => _status = ModelStatus.notInitialized;

  @override
  Stream<String> generate(String prompt) {
    return Stream.fromIterable([
      'The mind map explores AI concepts.',
      ' Key themes include machine learning.',
    ]);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('LLMAIService', () {
    late _MockLLMRuntime mockRuntime;
    late LLMAIService llmService;
    late AIContext testContext;

    setUp(() {
      mockRuntime = _MockLLMRuntime();
      llmService = LLMAIService(llmRuntime: mockRuntime);
      testContext = const AIContext(
        title: 'Test Mind',
        nodes: [],
        connections: [],
        nodeCount: 0,
        connectionCount: 0,
      );
    });

    test('uses LLM when runtime is ready', () async {
      final result = await llmService.analyze(
        context: testContext,
        config: const AIConfig(),
      );
      expect(
        result.analysisText,
        contains('The mind map explores AI concepts'),
      );
    });

    test('falls back to heuristic when runtime is not ready', () async {
      mockRuntime.setStatus(ModelStatus.unavailable);
      final result = await llmService.analyze(
        context: testContext,
        config: const AIConfig(),
      );
      expect(result.analysisText, contains('no nodes yet'));
    });

    test('falls back when runtime is not initialized', () async {
      mockRuntime.setStatus(ModelStatus.notInitialized);
      final result = await llmService.analyze(
        context: testContext,
        config: const AIConfig(),
      );
      expect(result.analysisText, contains('no nodes yet'));
    });

    test('falls back when runtime has error', () async {
      mockRuntime.setStatus(ModelStatus.error);
      final result = await llmService.analyze(
        context: testContext,
        config: const AIConfig(),
      );
      expect(result.analysisText, contains('no nodes yet'));
    });

    test('analyzeStreaming streams tokens when runtime ready', () async {
      final tokens = <String>[];
      await llmService
          .analyzeStreaming(context: testContext, config: const AIConfig())
          .forEach((token) => tokens.add(token));
      expect(tokens, isNotEmpty);
      expect(tokens.first, contains('mind map'));
    });

    test('analyzeStreaming falls back on unavailable runtime', () async {
      mockRuntime.setStatus(ModelStatus.unavailable);
      final tokens = <String>[];
      await llmService
          .analyzeStreaming(context: testContext, config: const AIConfig())
          .forEach((token) => tokens.add(token));
      expect(tokens, isNotEmpty);
    });

    test('handles empty context gracefully', () async {
      final result = await llmService.analyze(
        context: testContext,
        config: const AIConfig(),
      );
      expect(result, isA<AIResponse>());
    });

    test('passes context with nodes to LLM', () async {
      mockRuntime = _MockLLMRuntime();
      llmService = LLMAIService(llmRuntime: mockRuntime);
      final contextWithNodes = AIContext(
        title: 'AI Topics',
        nodes: [
          const AIContextNode(id: '1', content: 'Machine Learning'),
          const AIContextNode(
            id: '2',
            content: 'Neural Networks',
            tags: ['deep'],
          ),
        ],
        connections: [
          const AIContextConnection(sourceNodeId: '1', targetNodeId: '2'),
        ],
        nodeCount: 2,
        connectionCount: 1,
      );
      final result = await llmService.analyze(
        context: contextWithNodes,
        config: const AIConfig(),
      );
      expect(result, isA<AIResponse>());
    });

    test('LLMAIService is an AIService', () {
      expect(llmService, isA<AIService>());
    });
  });
}
