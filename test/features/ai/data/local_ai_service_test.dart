import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/ai/data/local_ai_service.dart';
import 'package:seima/features/ai/domain/ai_config.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';

void main() {
  group('LocalAIService', () {
    late LocalAIService service;

    setUp(() {
      service = const LocalAIService();
    });

    test('analyze returns response for non-empty mind', () async {
      final context = AIContext(
        title: 'Test Mind',
        nodes: [
          const AIContextNode(id: 'n1', content: 'Flutter development'),
          const AIContextNode(id: 'n2', content: 'Dart programming language'),
        ],
        connections: const [],
        nodeCount: 2,
        connectionCount: 0,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, isNotEmpty);
      expect(response.analysisText, contains('Test Mind'));
    });

    test('analyze returns empty response for empty mind', () async {
      final context = const AIContext(
        title: 'Empty',
        nodes: [],
        connections: [],
        nodeCount: 0,
        connectionCount: 0,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, contains('no nodes'));
      expect(response.proposals, isEmpty);
    });

    test('analyze detects isolated nodes', () async {
      final context = AIContext(
        title: 'Test',
        nodes: [
          const AIContextNode(id: 'n1', content: 'Node A'),
          const AIContextNode(id: 'n2', content: 'Node B'),
          const AIContextNode(id: 'n3', content: 'Node C'),
        ],
        connections: [
          const AIContextConnection(sourceNodeId: 'n1', targetNodeId: 'n2'),
        ],
        nodeCount: 3,
        connectionCount: 1,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, contains('Isolated'));
      expect(response.analysisText, contains('Node C'));
    });

    test('analyze suggests connections for overlapping content', () async {
      final context = AIContext(
        title: 'Test',
        nodes: [
          const AIContextNode(
            id: 'n1',
            content: 'Building with Flutter framework',
          ),
          const AIContextNode(
            id: 'n2',
            content: 'Flutter widgets and state management',
          ),
        ],
        connections: const [],
        nodeCount: 2,
        connectionCount: 0,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, isNotEmpty);
    });

    test('analyze includes themes in output', () async {
      final context = AIContext(
        title: 'Test',
        nodes: [
          const AIContextNode(id: 'n1', content: 'Machine learning basics'),
          const AIContextNode(id: 'n2', content: 'Deep learning concepts'),
          const AIContextNode(
            id: 'n3',
            content: 'Neural network architectures',
          ),
        ],
        connections: const [
          AIContextConnection(sourceNodeId: 'n1', targetNodeId: 'n2'),
          AIContextConnection(sourceNodeId: 'n2', targetNodeId: 'n3'),
        ],
        nodeCount: 3,
        connectionCount: 2,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, contains('3 nodes'));
      expect(response.analysisText, contains('2 connections'));
    });

    test('proposals are valid for small minds', () async {
      final context = AIContext(
        title: 'Small',
        nodes: [
          const AIContextNode(id: 'n1', content: 'Topic A'),
          const AIContextNode(id: 'n2', content: 'Topic B'),
        ],
        connections: const [],
        nodeCount: 2,
        connectionCount: 0,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      for (final proposal in response.proposals) {
        expect(proposal.reason, isNotEmpty);
        if (proposal is NewNodeProposal) {
          expect(proposal.content, isNotEmpty);
        }
        if (proposal is ConnectionProposal) {
          expect(proposal.sourceNodeId, isNotEmpty);
          expect(proposal.targetNodeId, isNotEmpty);
        }
      }
    });

    test('analyze handles single node mind', () async {
      final context = AIContext(
        title: 'Single',
        nodes: [const AIContextNode(id: 'n1', content: 'Just one idea')],
        connections: const [],
        nodeCount: 1,
        connectionCount: 0,
      );
      final response = await service.analyze(
        context: context,
        config: const AIConfig(),
      );
      expect(response.analysisText, isNotEmpty);
    });
  });
}
