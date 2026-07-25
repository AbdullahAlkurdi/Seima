import 'dart:async';
import 'package:mindora/features/ai/domain/ai_config.dart';
import 'package:mindora/features/ai/domain/ai_context.dart';
import 'package:mindora/features/ai/domain/ai_response.dart';

abstract class AIService {
  Future<AIResponse> analyze({
    required AIContext context,
    required AIConfig config,
  });

  Stream<String> analyzeStreaming({
    required AIContext context,
    required AIConfig config,
  });
}
