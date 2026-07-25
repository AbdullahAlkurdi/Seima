import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/ai/domain/ai_context.dart';

void main() {
  group('AIContext', () {
    test('creates with title and description', () {
      final context = const AIContext(
        title: 'Test Mind',
        description: 'A test',
        nodes: [],
        connections: [],
        nodeCount: 0,
        connectionCount: 0,
      );
      expect(context.title, 'Test Mind');
      expect(context.description, 'A test');
    });

    test('creates with nodes', () {
      final nodes = [
        const AIContextNode(id: 'n1', content: 'Node 1', tags: ['tag1']),
        const AIContextNode(id: 'n2', content: 'Node 2'),
      ];
      final context = AIContext(
        title: 'Test',
        nodes: nodes,
        connections: const [],
        nodeCount: 2,
        connectionCount: 0,
      );
      expect(context.nodes.length, 2);
      expect(context.nodes[0].tags, contains('tag1'));
      expect(context.nodes[1].content, 'Node 2');
    });

    test('creates with connections', () {
      final connections = [
        const AIContextConnection(sourceNodeId: 'n1', targetNodeId: 'n2'),
      ];
      final context = AIContext(
        title: 'Test',
        nodes: const [],
        connections: connections,
        nodeCount: 2,
        connectionCount: 1,
      );
      expect(context.connections.length, 1);
      expect(context.connections[0].sourceNodeId, 'n1');
      expect(context.connections[0].targetNodeId, 'n2');
    });
  });
}
