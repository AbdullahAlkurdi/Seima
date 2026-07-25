import 'dart:async';
import 'package:seima/features/ai/data/ai_service.dart';
import 'package:seima/features/ai/data/llm_response_parser.dart';
import 'package:seima/features/ai/data/llm_runtime.dart';
import 'package:seima/features/ai/data/local_ai_service.dart';
import 'package:seima/features/ai/data/mind_context_builder.dart';
import 'package:seima/features/ai/domain/ai_config.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/ai/domain/ai_failure.dart';
import 'package:seima/features/ai/domain/ai_response.dart';

class LLMAIService implements AIService {
  final LocalLLMRuntime llmRuntime;
  final MindContextBuilder contextBuilder;
  final LLMResponseParser parser;
  final LocalAIService fallback;

  const LLMAIService({
    required this.llmRuntime,
    this.contextBuilder = const MindContextBuilder(),
    this.parser = const LLMResponseParser(),
    this.fallback = const LocalAIService(),
  });

  @override
  Future<AIResponse> analyze({
    required AIContext context,
    required AIConfig config,
  }) async {
    final runtimeStatus = await llmRuntime.status;

    if (runtimeStatus != ModelStatus.ready) {
      return fallback.analyze(context: context, config: config);
    }

    try {
      final prompt = contextBuilder.toPrompt(context);
      final systemPrompt = _buildSystemPrompt();
      final fullPrompt = '$systemPrompt\n\nMind Map:\n$prompt';

      final output = await llmRuntime.generate(fullPrompt).join('\n');

      return parser.parse(output);
    } on AIFailure {
      rethrow;
    } catch (e) {
      throw AIFailure.unknown('LLM analysis failed: $e');
    }
  }

  @override
  Stream<String> analyzeStreaming({
    required AIContext context,
    required AIConfig config,
  }) {
    final controller = StreamController<String>();

    _runStreamingAnalysis(context, controller)
        .then((_) {
          if (!controller.isClosed) controller.close();
        })
        .catchError((error) {
          if (!controller.isClosed) {
            controller.addError(error);
            controller.close();
          }
        });

    return controller.stream;
  }

  Future<void> _runStreamingAnalysis(
    AIContext context,
    StreamController<String> controller,
  ) async {
    final runtimeStatus = await llmRuntime.status;

    if (runtimeStatus != ModelStatus.ready) {
      final fallbackResult = await fallback.analyze(
        context: context,
        config: const AIConfig(),
      );
      controller.add(fallbackResult.analysisText);
      return;
    }

    final prompt = contextBuilder.toPrompt(context);
    final systemPrompt = _buildSystemPrompt();
    final fullPrompt = '$systemPrompt\n\nMind Map:\n$prompt';

    await for (final token in llmRuntime.generate(fullPrompt)) {
      controller.add(token);
    }
  }

  String _buildSystemPrompt() {
    return 'You are a mind map analysis assistant. '
        'Analyze the given mind map and provide insights.\n\n'
        'First, write a brief analysis covering:\n'
        '- Summary of the mind map content\n'
        '- Key themes and patterns\n'
        '- Suggestions for expansion\n'
        '- Questions worth exploring\n\n'
        'Then, output a JSON block with any proposals:\n'
        '{\n'
        '  "proposals": [\n'
        '    {\n'
        '      "type": "new_node",\n'
        '      "content": "Suggested node content",\n'
        '      "tags": ["theme"],\n'
        '      "reason": "Why this node would be useful"\n'
        '    },\n'
        '    {\n'
        '      "type": "connection",\n'
        '      "source_id": "node-id-here",\n'
        '      "target_id": "node-id-here",\n'
        '      "reason": "Why these should be connected"\n'
        '    }\n'
        '  ]\n'
        '}';
  }
}
