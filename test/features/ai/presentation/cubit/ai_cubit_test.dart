import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:seima/features/ai/data/ai_service.dart';
import 'package:seima/features/ai/domain/ai_config.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';
import 'package:seima/features/ai/domain/ai_response.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/ai/presentation/cubit/ai_state.dart';

class _MockAIService implements AIService {
  final bool shouldFail;

  const _MockAIService({this.shouldFail = false});

  @override
  Future<AIResponse> analyze({
    required AIContext context,
    required AIConfig config,
  }) async {
    if (shouldFail) {
      throw Exception('AI failed');
    }
    return AIResponse(
      analysisText: 'Analysis result for ${context.title}',
      proposals: [
        NewNodeProposal(content: 'Suggested node', reason: 'Good idea'),
      ],
    );
  }

  @override
  Stream<String> analyzeStreaming({
    required AIContext context,
    required AIConfig config,
  }) async* {
    if (shouldFail) {
      throw Exception('AI failed');
    }
    yield 'Analysis result for ${context.title}';
  }
}

AIContext _testContext() => AIContext(
  title: 'Test',
  nodes: [const AIContextNode(id: 'n1', content: 'A')],
  connections: const [],
  nodeCount: 1,
  connectionCount: 0,
);

void main() {
  group('AICubit', () {
    test('initial state is initial with panel closed', () {
      final cubit = AICubit(aiService: const _MockAIService());
      expect(cubit.state.status, AIStatus.initial);
      expect(cubit.state.isPanelOpen, false);
      expect(cubit.state.analysisText, isNull);
      expect(cubit.state.proposals, isEmpty);
    });

    test('initial modelState is unknown', () {
      final cubit = AICubit(aiService: const _MockAIService());
      expect(cubit.state.modelState, ModelState.unknown);
    });

    blocTest<AICubit, AIState>(
      'openPanel opens the panel',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.openPanel(),
      verify: (cubit) {
        expect(cubit.state.isPanelOpen, true);
      },
    );

    blocTest<AICubit, AIState>(
      'closePanel closes the panel',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) => cubit.closePanel(),
      verify: (cubit) {
        expect(cubit.state.isPanelOpen, false);
      },
    );

    blocTest<AICubit, AIState>(
      'analyze sets loading then success with proposals',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyze();
      },
      expect: () => [
        isA<AIState>()
            .having((s) => s.status, 'loading', AIStatus.loading)
            .having((s) => s.analysisText, 'no text yet', isNull),
        isA<AIState>()
            .having((s) => s.status, 'success', AIStatus.success)
            .having((s) => s.analysisText, 'has analysis', isNotEmpty)
            .having((s) => s.proposals.length, 'has proposals', 1),
      ],
    );

    blocTest<AICubit, AIState>(
      'analyze handles failure',
      build: () => AICubit(aiService: const _MockAIService(shouldFail: true)),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyze();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.failure);
        expect(cubit.state.hasError, true);
        expect(cubit.state.failure, isNotNull);
      },
    );

    blocTest<AICubit, AIState>(
      'clearAnalysis resets state',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.clearAnalysis(),
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.initial);
        expect(cubit.state.analysisText, isNull);
        expect(cubit.state.proposals, isEmpty);
        expect(cubit.state.failure, isNull);
      },
    );

    blocTest<AICubit, AIState>(
      'analyze without setting context does nothing',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.analyze(),
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.initial);
      },
    );

    blocTest<AICubit, AIState>(
      'modelState becomes notAvailable when no model manager',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.openPanel(),
      verify: (cubit) {
        expect(cubit.state.modelState, ModelState.notAvailable);
      },
    );

    blocTest<AICubit, AIState>(
      'downloadModel sets error when no model manager',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.downloadModel(),
      verify: (cubit) {
        expect(cubit.state.modelState, ModelState.error);
        expect(cubit.state.failure, isNotNull);
      },
    );

    blocTest<AICubit, AIState>(
      'analyzeStreaming without context does nothing',
      build: () => AICubit(aiService: const _MockAIService()),
      act: (cubit) => cubit.analyzeStreaming(),
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.initial);
      },
    );

    blocTest<AICubit, AIState>(
      'analyzeStreaming with context falls back to analyze when model not ready',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyzeStreaming();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.success);
        expect(cubit.state.analysisText, isNotEmpty);
      },
    );

    blocTest<AICubit, AIState>(
      'analyze rejects concurrent calls',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyze();
        cubit.analyze();
        cubit.analyze();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.success);
      },
    );

    blocTest<AICubit, AIState>(
      'analyze allows retry after completion',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) async {
        cubit.setContext(_testContext());
        cubit.analyze();
        await Future.delayed(const Duration(milliseconds: 50));
        cubit.analyze();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.success);
      },
    );

    blocTest<AICubit, AIState>(
      'analyzeStreaming rejects concurrent calls',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyzeStreaming();
        cubit.analyzeStreaming();
        cubit.analyzeStreaming();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.success);
      },
    );

    blocTest<AICubit, AIState>(
      'analyze does not hang after cancel',
      build: () => AICubit(aiService: const _MockAIService()),
      seed: () => const AIState(isPanelOpen: true),
      act: (cubit) {
        cubit.setContext(_testContext());
        cubit.analyzeStreaming();
        cubit.closePanel();
        cubit.openPanel();
        cubit.setContext(_testContext());
        cubit.analyze();
      },
      verify: (cubit) {
        expect(cubit.state.status, AIStatus.success);
      },
    );
  });
}
