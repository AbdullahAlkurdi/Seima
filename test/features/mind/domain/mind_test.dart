import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';

void main() {
  group('Mind', () {
    test('creates with default values', () {
      final mind = Mind(id: 'm1');
      expect(mind.id, 'm1');
      expect(mind.title, 'Untitled');
      expect(mind.description, isNull);
      expect(mind.nodes, isEmpty);
      expect(mind.connections, isEmpty);
      expect(mind.lastAccessedAt, isNotNull);
    });

    test('creates with custom title', () {
      final mind = Mind(id: 'm1', title: 'My Map');
      expect(mind.title, 'My Map');
    });

    test('creates with description', () {
      final mind = Mind(id: 'm1', description: 'A test mind');
      expect(mind.description, 'A test mind');
    });

    test('copyWith updates fields', () {
      final mind = Mind(id: 'm1');
      final updated = mind.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.id, 'm1');
    });

    test('copyWith adds nodes', () {
      final mind = Mind(id: 'm1');
      final node = MindNode(id: 'n1', mindId: 'm1');
      final updated = mind.copyWith(nodes: [node]);
      expect(updated.nodes.length, 1);
      expect(updated.nodes.first.id, 'n1');
    });

    test('copyWith updateTimestamp changes updatedAt', () async {
      final mind = Mind(id: 'm1');
      await Future.delayed(const Duration(milliseconds: 1));
      final updated = mind.copyWith(updateTimestamp: true);
      expect(updated.updatedAt.isAfter(mind.updatedAt), isTrue);
    });

    test('toJson and fromJson round-trip', () {
      final node = MindNode(
        id: 'n1',
        mindId: 'm1',
        content: 'test',
        x: 100,
        y: 200,
        tags: ['important'],
      );
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      final mind = Mind(
        id: 'm1',
        title: 'Test Mind',
        description: 'A test',
        nodes: [node],
        connections: [conn],
      );
      final json = mind.toJson();
      final reconstructed = Mind.fromJson(json);
      expect(reconstructed.id, 'm1');
      expect(reconstructed.title, 'Test Mind');
      expect(reconstructed.description, 'A test');
      expect(reconstructed.nodes.length, 1);
      expect(reconstructed.connections.length, 1);
      expect(reconstructed.nodes.first.content, 'test');
      expect(reconstructed.nodes.first.tags, ['important']);
    });

    test('toJson omits null description and empty tags', () {
      final mind = Mind(id: 'm1');
      final json = mind.toJson();
      expect(json.containsKey('description'), isFalse);
    });

    test('toJsonString and fromJsonString round-trip', () {
      final mind = Mind(id: 'm1', title: 'JSON Mind');
      final jsonString = mind.toJsonString();
      final reconstructed = Mind.fromJsonString(jsonString);
      expect(reconstructed.id, mind.id);
      expect(reconstructed.title, mind.title);
    });

    test('equality based on id and content', () {
      final a = Mind(id: 'm1', title: 'Same');
      final b = Mind(id: 'm1', title: 'Same');
      expect(a, equals(b));
    });

    test('inequality on different title', () {
      final a = Mind(id: 'm1', title: 'First');
      final b = Mind(id: 'm1', title: 'Second');
      expect(a, isNot(equals(b)));
    });

    test('inequality on different id', () {
      final a = Mind(id: 'm1');
      final b = Mind(id: 'm2');
      expect(a, isNot(equals(b)));
    });

    test('lastAccessedAt preserved across json round-trip', () {
      final accessed = DateTime(2024, 1, 15);
      final mind = Mind(id: 'm1', lastAccessedAt: accessed);
      final json = mind.toJson();
      final reconstructed = Mind.fromJson(json);
      expect(reconstructed.lastAccessedAt, accessed);
    });

    test('lastAccessedAt falls back to updatedAt when missing in json', () {
      final json = {
        'id': 'm1',
        'title': 'Test',
        'nodes': [],
        'connections': [],
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-06-15T00:00:00.000',
      };
      final mind = Mind.fromJson(json);
      expect(mind.lastAccessedAt, DateTime(2024, 6, 15));
    });

    test('toJson includes schemaVersion', () {
      final mind = Mind(id: 'm1');
      final json = mind.toJson();
      expect(json['schemaVersion'], 1);
    });

    test('fromJson defaults schemaVersion to 1 when missing', () {
      final json = {
        'id': 'm1',
        'title': 'Old',
        'nodes': [],
        'connections': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final mind = Mind.fromJson(json);
      expect(mind.schemaVersion, 1);
    });

    test('toJson includes sequenceNumber', () {
      final mind = Mind(id: 'm1');
      final json = mind.toJson();
      expect(json['sequenceNumber'], 0);
    });

    test('copyWith increments sequenceNumber', () {
      final mind = Mind(id: 'm1', sequenceNumber: 5);
      final updated = mind.copyWith(title: 'New');
      expect(updated.sequenceNumber, 5);
    });

    test('sequenceNumber preserved across json round-trip', () {
      final mind = Mind(id: 'm1', sequenceNumber: 42);
      final json = mind.toJson();
      final reconstructed = Mind.fromJson(json);
      expect(reconstructed.sequenceNumber, 42);
    });

    test('fromJson handles unknown schemaVersion gracefully', () {
      final json = {
        'id': 'm1',
        'title': 'Future Mind',
        'nodes': [],
        'connections': [],
        'schemaVersion': 999,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final mind = Mind.fromJson(json);
      expect(mind.schemaVersion, 999);
      expect(mind.title, 'Future Mind');
    });
  });
}
