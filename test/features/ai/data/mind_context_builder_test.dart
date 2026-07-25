import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/ai/data/mind_context_builder.dart';
import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/mind_node.dart';

void main() {
  group('MindContextBuilder', () {
    late MindContextBuilder builder;

    setUp(() {
      builder = const MindContextBuilder();
    });

    test('builds context from mind with nodes and connections', () {
      final mind = Mind(
        id: 'm1',
        title: 'Project Ideas',
        description: 'My project ideas',
        nodes: [
          MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'Build app',
            tags: ['flutter'],
          ),
          MindNode(id: 'n2', mindId: 'm1', content: 'Learn Rust'),
        ],
        connections: [
          MindConnection(
            id: 'c1',
            mindId: 'm1',
            sourceNodeId: 'n1',
            targetNodeId: 'n2',
          ),
        ],
      );

      final context = builder.build(mind);
      expect(context.title, 'Project Ideas');
      expect(context.description, 'My project ideas');
      expect(context.nodes.length, 2);
      expect(context.connections.length, 1);
      expect(context.nodeCount, 2);
      expect(context.connectionCount, 1);
    });

    test('builds context from empty mind', () {
      final mind = Mind(id: 'm1', title: 'Empty');
      final context = builder.build(mind);
      expect(context.nodes, isEmpty);
      expect(context.connections, isEmpty);
      expect(context.nodeCount, 0);
      expect(context.connectionCount, 0);
    });

    test('includes node tags in context', () {
      final mind = Mind(
        id: 'm1',
        title: 'Test',
        nodes: [
          MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'A',
            tags: ['urgent', 'idea'],
          ),
        ],
      );
      final context = builder.build(mind);
      expect(context.nodes.first.tags, contains('urgent'));
      expect(context.nodes.first.tags, contains('idea'));
    });

    test('context is deterministic for same mind', () {
      final mind = Mind(
        id: 'm1',
        title: 'Test',
        nodes: [MindNode(id: 'n1', mindId: 'm1', content: 'Content')],
      );
      final context1 = builder.build(mind);
      final context2 = builder.build(mind);
      expect(context1.nodes.length, context2.nodes.length);
      expect(context1.nodes.first.content, context2.nodes.first.content);
    });

    test('toPrompt formats context correctly', () {
      final context = AIContext(
        title: 'Test Mind',
        description: 'Desc',
        nodes: [
          const AIContextNode(id: 'n1', content: 'Node content', tags: ['tag']),
        ],
        connections: [
          const AIContextConnection(sourceNodeId: 'n1', targetNodeId: 'n2'),
        ],
        nodeCount: 2,
        connectionCount: 1,
      );
      final prompt = builder.toPrompt(context);
      expect(prompt, contains('Test Mind'));
      expect(prompt, contains('Desc'));
      expect(prompt, contains('n1'));
      expect(prompt, contains('Node content'));
      expect(prompt, contains('tag'));
    });
  });
}
