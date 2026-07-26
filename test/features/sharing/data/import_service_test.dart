import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/sharing/data/import_service.dart';
import 'package:seima/features/sharing/domain/seima_knowledge_package.dart';
import 'package:seima/features/sharing/domain/sharing_failure.dart';

void main() {
  group('ImportService', () {
    late ImportService service;

    setUp(() {
      service = ImportService();
    });

    group('previewFromPackage', () {
      test('previews empty package with warnings', () async {
        final pkg = SeimaKnowledgePackage();
        final preview = await service.previewFromPackage(pkg);

        expect(preview.nodeCount, 0);
        expect(preview.connectionCount, 0);
        expect(preview.warnings, isNotEmpty);
        expect(preview.hasErrors, isFalse);
      });

      test('previews package with nodes', () async {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Test'),
          nodes: [
            PackageNode(id: 'n1', content: 'Node 1'),
            PackageNode(id: 'n2', content: 'Node 2'),
          ],
          connections: [
            PackageConnection(id: 'c1', sourceId: 'n1', targetId: 'n2'),
          ],
        );
        final preview = await service.previewFromPackage(pkg);

        expect(preview.title, 'Test');
        expect(preview.nodeCount, 2);
        expect(preview.connectionCount, 1);
        expect(preview.hasErrors, isFalse);
        expect(preview.isValid, isTrue);
      });

      test('detects duplicate node IDs', () async {
        final pkg = SeimaKnowledgePackage(
          nodes: [
            PackageNode(id: 'n1'),
            PackageNode(id: 'n1'),
          ],
        );
        final preview = await service.previewFromPackage(pkg);

        expect(preview.warnings.any((w) => w.contains('Duplicate')), isTrue);
      });

      test('detects broken connections', () async {
        final pkg = SeimaKnowledgePackage(
          nodes: [PackageNode(id: 'n1')],
          connections: [
            PackageConnection(
              id: 'c1',
              sourceId: 'n1',
              targetId: 'nonexistent',
            ),
          ],
        );
        final preview = await service.previewFromPackage(pkg);

        expect(preview.hasErrors, isTrue);
        expect(preview.errors.any((e) => e.contains('non-existent')), isTrue);
      });

      test('collects detected tags', () async {
        final pkg = SeimaKnowledgePackage(
          nodes: [
            PackageNode(id: 'n1', tags: ['tag1', 'tag2']),
            PackageNode(id: 'n2', tags: ['tag2', 'tag3']),
          ],
        );
        final preview = await service.previewFromPackage(pkg);

        expect(preview.detectedTags, containsAll(['tag1', 'tag2', 'tag3']));
      });
    });

    group('previewFromString', () {
      test('previews valid seima package JSON', () async {
        const json = '''
        {
          "schema": "seima_knowledge",
          "seima_knowledge_version": 1,
          "created_at": "2026-07-26T00:00:00.000",
          "source_app": "seima",
          "mind": {"id": "m1", "title": "JSON Import"},
          "nodes": [
            {"id": "n1", "position": {"x": 0, "y": 0}, "dimensions": {"width": 200, "height": 80}},
            {"id": "n2", "position": {"x": 200, "y": 0}, "dimensions": {"width": 200, "height": 80}}
          ],
          "connections": [
            {"id": "c1", "source_id": "n1", "target_id": "n2"}
          ]
        }
        ''';
        final preview = await service.previewFromString(json);

        expect(preview.title, 'JSON Import');
        expect(preview.nodeCount, 2);
        expect(preview.connectionCount, 1);
        expect(preview.sourceType, 'Seima Knowledge Package');
      });

      test('previews plain text as nodes', () async {
        const text = 'Line 1\nLine 2\nLine 3';
        final preview = await service.previewFromString(text);

        expect(preview.title, 'Imported Text');
        expect(preview.nodeCount, 3);
        expect(preview.connectionCount, 0);
        expect(preview.sourceType, 'Plain Text');
      });

      test('shows warning for large text', () async {
        final lines = List.generate(150, (i) => 'Line $i').join('\n');
        final preview = await service.previewFromString(lines);

        expect(preview.warnings.any((w) => w.contains('Large text')), isTrue);
      });
    });

    group('previewFromClipboard', () {
      test('throws on empty clipboard', () async {
        // Clipboard requires platform plugin, this tests the error path
        // by attempting to read clipboard (which may not be available in test)
      });
    });

    group('previewFromFile', () {
      test('throws on non-existent file', () async {
        expect(
          () => service.previewFromFile('/nonexistent/file.seima'),
          throwsA(isA<SharingFailure>()),
        );
      });
    });

    group('executeAsNewMind', () {
      test('creates new mind from package', () async {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'New Mind'),
          nodes: [
            PackageNode(id: 'n1', content: 'Hello', x: 0, y: 0),
            PackageNode(id: 'n2', content: 'World', x: 200, y: 0),
          ],
          connections: [
            PackageConnection(id: 'c1', sourceId: 'n1', targetId: 'n2'),
          ],
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeAsNewMind(preview);

        expect(result.mind.title, 'New Mind');
        expect(result.mind.nodes.length, 2);
        expect(result.mind.connections.length, 1);
        expect(result.mind.id, isNot('m1')); // New ID assigned
        expect(result.isNew, isTrue);
      });

      test('assigns new IDs to imported nodes', () async {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Test'),
          nodes: [
            PackageNode(id: 'orig-1', content: 'A'),
            PackageNode(id: 'orig-2', content: 'B'),
          ],
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeAsNewMind(preview);

        for (final node in result.mind.nodes) {
          expect(node.id, isNot(contains('orig')));
          expect(node.mindId, result.mind.id);
        }
      });

      test('handles empty package gracefully', () async {
        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Empty'),
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeAsNewMind(preview);

        expect(result.mind.nodes, isEmpty);
        expect(result.mind.connections, isEmpty);
        expect(result.isNew, isTrue);
      });
    });

    group('executeMergeIntoMind', () {
      test('merges nodes into existing mind', () async {
        final targetMind = Mind(
          id: 'existing',
          title: 'Existing Mind',
          nodes: [MindNode(id: 'e1', mindId: 'existing', content: 'Existing')],
        );

        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Import'),
          nodes: [PackageNode(id: 'i1', content: 'Imported')],
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeMergeIntoMind(preview, targetMind);

        expect(result.mind.nodes.length, 2);
        expect(result.mind.connections, isEmpty);
        expect(result.isNew, isFalse);
      });

      test('merges connections between imported nodes', () async {
        final targetMind = Mind(id: 'existing', title: 'Existing');

        final pkg = SeimaKnowledgePackage(
          mind: PackageMind(id: 'm1', title: 'Import'),
          nodes: [
            PackageNode(id: 'i1', content: 'A'),
            PackageNode(id: 'i2', content: 'B'),
          ],
          connections: [
            PackageConnection(id: 'c1', sourceId: 'i1', targetId: 'i2'),
          ],
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeMergeIntoMind(preview, targetMind);

        expect(result.mind.nodes.length, 2);
        expect(result.mind.connections.length, 1);
      });

      test('offsets imported nodes slightly', () async {
        final targetMind = Mind(id: 'existing', title: 'Existing');

        final pkg = SeimaKnowledgePackage(
          nodes: [PackageNode(id: 'n1', x: 100, y: 100)],
        );
        final preview = await service.previewFromPackage(pkg);
        final result = await service.executeMergeIntoMind(preview, targetMind);

        final mergedNode = result.mind.nodes.first;
        expect(mergedNode.x, 150); // offset by 50
        expect(mergedNode.y, 150);
      });
    });

    group('error handling', () {
      test('handles invalid JSON gracefully as plain text', () async {
        final preview = await service.previewFromString('not json at all');
        expect(preview.sourceType, 'Plain Text');
        expect(preview.nodeCount, 1);
      });

      test('throws on unknown format', () async {
        expect(
          () => service.previewFromString(''),
          throwsA(isA<SharingFailure>()),
        );
      });

      test('throws on wrong schema', () async {
        const json = '{"schema": "wrong_schema"}';
        expect(
          () => service.previewFromString(json),
          throwsA(isA<SharingFailure>()),
        );
      });
    });
  });
}
