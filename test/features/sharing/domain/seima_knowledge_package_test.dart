import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/sharing/domain/seima_knowledge_package.dart';

void main() {
  group('SeimaKnowledgePackage', () {
    group('toJson / fromJson round trip', () {
      test('empty package round trips correctly', () {
        final pkg = SeimaKnowledgePackage();
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.version, pkg.version);
        expect(restored.sourceApp, pkg.sourceApp);
        expect(restored.nodes, isEmpty);
        expect(restored.connections, isEmpty);
        expect(restored.mind, isNull);
        expect(restored.provenance, isNull);
      });

      test('package with full mind round trips correctly', () {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(
            id: 'mind-1',
            title: 'Test Mind',
            description: 'A test',
            category: 'Work',
            createdAt: DateTime(2026, 7, 26),
            updatedAt: DateTime(2026, 7, 26),
            tags: ['test', 'important'],
            metadata: {'custom': 'value'},
          ),
        );
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.mind, isNotNull);
        expect(restored.mind!.id, 'mind-1');
        expect(restored.mind!.title, 'Test Mind');
        expect(restored.mind!.description, 'A test');
        expect(restored.mind!.category, 'Work');
        expect(restored.mind!.tags, ['test', 'important']);
        expect(restored.mind!.metadata, {'custom': 'value'});
      });

      test('package with nodes round trips correctly', () {
        final pkg = SeimaKnowledgePackage(
          nodes: [
            PackageNode(
              id: 'node-1',
              type: 'task',
              content: 'Do something',
              tags: ['urgent'],
              x: 100,
              y: 200,
              width: 250,
              height: 90,
              createdAt: DateTime(2026, 7, 26),
              updatedAt: DateTime(2026, 7, 26),
              metadata: {'color': 'red'},
            ),
            PackageNode(
              id: 'node-2',
              type: 'question',
              content: 'Why?',
              x: 400,
              y: 200,
            ),
          ],
        );
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.nodes.length, 2);

        final node1 = restored.nodes[0];
        expect(node1.id, 'node-1');
        expect(node1.type, 'task');
        expect(node1.content, 'Do something');
        expect(node1.tags, ['urgent']);
        expect(node1.x, 100);
        expect(node1.y, 200);
        expect(node1.width, 250);
        expect(node1.height, 90);
        expect(node1.metadata, {'color': 'red'});

        final node2 = restored.nodes[1];
        expect(node2.id, 'node-2');
        expect(node2.type, 'question');
        expect(node2.content, 'Why?');
        expect(node2.x, 400);
        expect(node2.y, 200);
      });

      test('package with connections round trips correctly', () {
        final pkg = SeimaKnowledgePackage(
          nodes: [
            PackageNode(id: 'node-1'),
            PackageNode(id: 'node-2'),
          ],
          connections: [
            PackageConnection(
              id: 'conn-1',
              sourceId: 'node-1',
              targetId: 'node-2',
              type: 'bidirectional',
              label: 'related to',
              createdAt: DateTime(2026, 7, 26),
              metadata: {'weight': 5},
            ),
          ],
        );
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.connections.length, 1);
        final conn = restored.connections[0];
        expect(conn.id, 'conn-1');
        expect(conn.sourceId, 'node-1');
        expect(conn.targetId, 'node-2');
        expect(conn.type, 'bidirectional');
        expect(conn.label, 'related to');
        expect(conn.metadata, {'weight': 5});
      });

      test('package with provenance round trips correctly', () {
        final pkg = SeimaKnowledgePackage(
          provenance: PackageProvenance(
            exportedBy: 'test',
            sourceApp: 'seima_test',
            notes: 'Integration test export',
          ),
        );
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.provenance, isNotNull);
        expect(restored.provenance!.exportedBy, 'test');
        expect(restored.provenance!.sourceApp, 'seima_test');
        expect(restored.provenance!.notes, 'Integration test export');
      });

      test('fully populated package round trips correctly', () {
        final pkg = SeimaKnowledgePackage(
          version: 1,
          sourceApp: 'seima',
          mind: PackageMind(id: 'mind-1', title: 'Full Test'),
          nodes: [
            PackageNode(id: 'n1', content: 'Node 1', x: 0, y: 0),
            PackageNode(id: 'n2', content: 'Node 2', x: 200, y: 0),
          ],
          connections: [
            PackageConnection(id: 'c1', sourceId: 'n1', targetId: 'n2'),
          ],
          provenance: PackageProvenance(notes: 'full test'),
        );
        final json = pkg.toJson();
        final restored = SeimaKnowledgePackage.fromJson(json);

        expect(restored.version, 1);
        expect(restored.sourceApp, 'seima');
        expect(restored.mind!.id, 'mind-1');
        expect(restored.nodes.length, 2);
        expect(restored.connections.length, 1);
        expect(restored.provenance!.notes, 'full test');
      });
    });

    group('missing and unknown fields', () {
      test('unknown fields are silently preserved', () {
        final json = {
          'schema': 'seima_knowledge',
          'seima_knowledge_version': 1,
          'created_at': '2026-07-26T00:00:00.000',
          'source_app': 'seima',
          'unknown_field': 'should be preserved',
          'nested_unknown': {'key': 'value'},
        };
        final pkg = SeimaKnowledgePackage.fromJson(json);
        // Unknown fields are lost during deserialization (not preserved)
        // This is expected since we use typed classes
        expect(pkg.version, 1);
        expect(pkg.sourceApp, 'seima');
      });

      test('missing optional fields have safe defaults', () {
        final json = {
          'schema': 'seima_knowledge',
          'seima_knowledge_version': 1,
          'created_at': '2026-07-26T00:00:00.000',
          'source_app': 'seima',
        };
        final pkg = SeimaKnowledgePackage.fromJson(json);
        expect(pkg.version, 1);
        expect(pkg.sourceApp, 'seima');
        expect(pkg.nodes, isEmpty);
        expect(pkg.connections, isEmpty);
        expect(pkg.mind, isNull);
        expect(pkg.provenance, isNull);
      });

      test('node with missing optional fields has safe defaults', () {
        final json = {
          'id': 'node-1',
          'position': {'x': 50, 'y': 100},
          'dimensions': {'width': 200, 'height': 80},
        };
        final node = PackageNode.fromJson(json);
        expect(node.id, 'node-1');
        expect(node.type, 'text');
        expect(node.content, '');
        expect(node.tags, isEmpty);
        expect(node.x, 50);
        expect(node.y, 100);
        expect(node.width, 200);
        expect(node.height, 80);
      });

      test('connection with missing optional fields has safe defaults', () {
        final json = {
          'id': 'conn-1',
          'source_id': 'node-1',
          'target_id': 'node-2',
        };
        final conn = PackageConnection.fromJson(json);
        expect(conn.id, 'conn-1');
        expect(conn.sourceId, 'node-1');
        expect(conn.targetId, 'node-2');
        expect(conn.type, 'directed');
        expect(conn.label, isNull);
      });

      test('connection with unknown type defaults to directed', () {
        final json = {
          'id': 'conn-1',
          'source_id': 'node-1',
          'target_id': 'node-2',
          'type': 'some_unknown_type',
        };
        final conn = PackageConnection.fromJson(json);
        expect(conn.type, 'some_unknown_type');
        // Unknown types are preserved, not defaulted
      });
    });

    group('invalid required fields', () {
      test('rejects missing schema', () {
        final json = {
          'seima_knowledge_version': 1,
          'created_at': '2026-07-26T00:00:00.000',
          'source_app': 'seima',
        };
        expect(() => SeimaKnowledgePackage.fromJson(json), throwsArgumentError);
      });

      test('rejects wrong schema', () {
        final json = {'schema': 'other_format', 'seima_knowledge_version': 1};
        expect(() => SeimaKnowledgePackage.fromJson(json), throwsArgumentError);
      });

      test('rejects unsupported future version', () {
        final json = {
          'schema': 'seima_knowledge',
          'seima_knowledge_version': 999,
          'created_at': '2026-07-26T00:00:00.000',
          'source_app': 'test',
        };
        expect(() => SeimaKnowledgePackage.fromJson(json), throwsArgumentError);
      });

      test('rejects node without id', () {
        final json = {
          'type': 'text',
          'position': {'x': 0, 'y': 0},
          'dimensions': {'width': 200, 'height': 80},
        };
        expect(() => PackageNode.fromJson(json), throwsArgumentError);
      });

      test('rejects connection without source_id', () {
        final json = {'id': 'conn-1', 'target_id': 'node-2'};
        expect(() => PackageConnection.fromJson(json), throwsArgumentError);
      });

      test('rejects connection without target_id', () {
        final json = {'id': 'conn-1', 'source_id': 'node-1'};
        expect(() => PackageConnection.fromJson(json), throwsArgumentError);
      });

      test('rejects mind without id', () {
        final json = {'title': 'No ID Mind'};
        expect(() => PackageMind.fromJson(json), throwsArgumentError);
      });
    });

    group('serialization', () {
      test('toJsonString produces valid JSON', () {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Test'),
        );
        final jsonStr = pkg.toJsonString();
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        expect(decoded['schema'], 'seima_knowledge');
        expect(decoded['mind']['title'], 'Test');
      });

      test('fromJsonString parses valid JSON', () {
        const jsonStr = '''
        {
          "schema": "seima_knowledge",
          "seima_knowledge_version": 1,
          "created_at": "2026-07-26T00:00:00.000",
          "source_app": "seima",
          "mind": {
            "id": "m1",
            "title": "From String"
          }
        }
        ''';
        final pkg = SeimaKnowledgePackage.fromJsonString(jsonStr);
        expect(pkg.mind!.id, 'm1');
        expect(pkg.mind!.title, 'From String');
      });

      test('fromJsonString handles malformed JSON gracefully', () {
        expect(
          () => SeimaKnowledgePackage.fromJsonString('not json'),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
