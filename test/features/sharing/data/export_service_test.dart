import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/node_type.dart';
import 'package:seima/features/sharing/data/export_service.dart';

Mind createTestMind() {
  return Mind(
    id: 'test-mind-1',
    title: 'Test Mind',
    description: 'A mind for testing',
    category: 'Testing',
    nodes: [
      MindNode(
        id: 'node-1',
        mindId: 'test-mind-1',
        type: NodeType.text,
        content: 'Root node',
        x: 100,
        y: 200,
        width: 200,
        height: 80,
        tags: ['important'],
      ),
      MindNode(
        id: 'node-2',
        mindId: 'test-mind-1',
        type: NodeType.task,
        content: 'Task node',
        tags: ['todo'],
        x: 400,
        y: 200,
      ),
      MindNode(
        id: 'node-3',
        mindId: 'test-mind-1',
        type: NodeType.question,
        content: 'Question node',
        x: 100,
        y: 400,
      ),
    ],
    connections: [
      MindConnection(
        id: 'conn-1',
        mindId: 'test-mind-1',
        sourceNodeId: 'node-1',
        targetNodeId: 'node-2',
      ),
      MindConnection(
        id: 'conn-2',
        mindId: 'test-mind-1',
        sourceNodeId: 'node-1',
        targetNodeId: 'node-3',
      ),
    ],
  );
}

void main() {
  group('ExportService', () {
    late ExportService service;
    late Mind testMind;

    setUp(() {
      service = ExportService();
      testMind = createTestMind();
    });

    group('exportMind', () {
      test('converts mind to package with all data', () {
        final pkg = service.exportMind(testMind);

        expect(pkg.mind, isNotNull);
        expect(pkg.mind!.id, 'test-mind-1');
        expect(pkg.mind!.title, 'Test Mind');
        expect(pkg.mind!.description, 'A mind for testing');
        expect(pkg.mind!.category, 'Testing');

        expect(pkg.nodes.length, 3);
        expect(pkg.connections.length, 2);
      });

      test('preserves node types', () {
        final pkg = service.exportMind(testMind);

        final types = pkg.nodes.map((n) => n.type).toSet();
        expect(types, contains('text'));
        expect(types, contains('task'));
        expect(types, contains('question'));
      });

      test('preserves node positions', () {
        final pkg = service.exportMind(testMind);

        final rootNode = pkg.nodes.firstWhere((n) => n.id == 'node-1');
        expect(rootNode.x, 100);
        expect(rootNode.y, 200);
        expect(rootNode.width, 200);
        expect(rootNode.height, 80);
      });

      test('preserves node tags', () {
        final pkg = service.exportMind(testMind);

        final rootNode = pkg.nodes.firstWhere((n) => n.id == 'node-1');
        expect(rootNode.tags, ['important']);

        final taskNode = pkg.nodes.firstWhere((n) => n.id == 'node-2');
        expect(taskNode.tags, ['todo']);
      });

      test('preserves connections', () {
        final pkg = service.exportMind(testMind);

        expect(pkg.connections.length, 2);
        final conn1 = pkg.connections.firstWhere((c) => c.id == 'conn-1');
        expect(conn1.sourceId, 'node-1');
        expect(conn1.targetId, 'node-2');
      });

      test('adds provenance', () {
        final pkg = service.exportMind(testMind);

        expect(pkg.provenance, isNotNull);
        expect(pkg.provenance!.exportedBy, 'seima_export');
        expect(pkg.provenance!.sourceApp, 'seima');
        expect(pkg.provenance!.notes, isNotNull);
      });
    });

    group('exportNodes', () {
      test('exports only selected nodes and their connections', () {
        final selectedNodes = testMind.nodes
            .where((n) => n.id == 'node-1' || n.id == 'node-2')
            .toList();

        final pkg = service.exportNodes(
          mind: testMind,
          selectedNodes: selectedNodes,
        );

        expect(pkg.nodes.length, 2);
        expect(pkg.nodes.map((n) => n.id), containsAll(['node-1', 'node-2']));
        expect(pkg.nodes.map((n) => n.id), isNot(contains('node-3')));

        // Connection between node-1 and node-2 should be included
        expect(pkg.connections.length, 1);
        expect(pkg.connections.first.sourceId, 'node-1');
        expect(pkg.connections.first.targetId, 'node-2');
      });

      test('excludes connections to non-selected nodes', () {
        final selectedNodes = testMind.nodes
            .where((n) => n.id == 'node-2')
            .toList();

        final pkg = service.exportNodes(
          mind: testMind,
          selectedNodes: selectedNodes,
        );

        expect(pkg.nodes.length, 1);
        expect(pkg.connections, isEmpty);
      });
    });

    group('exportToText', () {
      test('produces human-readable text', () {
        final text = service.exportToText(testMind);

        expect(text, contains('Test Mind'));
        expect(text, contains('A mind for testing'));
        expect(text, contains('Root node'));
        expect(text, contains('Task node'));
        expect(text, contains('Question node'));
        expect(text, contains('Seima'));
      });
    });

    group('round trip', () {
      test('export → package → mind preserves semantic content', () {
        final pkg = service.exportMind(testMind);

        // Verify package structure matches original mind
        expect(pkg.mind!.title, testMind.title);
        expect(pkg.mind!.description, testMind.description);
        expect(pkg.nodes.length, testMind.nodes.length);
        expect(pkg.connections.length, testMind.connections.length);

        // Verify all node content is preserved
        for (final node in testMind.nodes) {
          final pkgNode = pkg.nodes.firstWhere((n) => n.id == node.id);
          expect(pkgNode.content, node.content);
          expect(pkgNode.type, node.type.name);
          expect(pkgNode.tags, node.tags);
          expect(pkgNode.x, node.x);
          expect(pkgNode.y, node.y);
        }

        // Verify all connections are preserved
        for (final conn in testMind.connections) {
          final pkgConn = pkg.connections.firstWhere((c) => c.id == conn.id);
          expect(pkgConn.sourceId, conn.sourceNodeId);
          expect(pkgConn.targetId, conn.targetNodeId);
        }
      });
    });
  });
}
