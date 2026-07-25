import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/domain/node_type.dart';

void main() {
  group('MindNode', () {
    test('creates with default values', () {
      final node = MindNode(id: '1', mindId: 'm1');
      expect(node.id, '1');
      expect(node.mindId, 'm1');
      expect(node.type, NodeType.text);
      expect(node.content, '');
      expect(node.tags, isEmpty);
      expect(node.x, 0);
      expect(node.y, 0);
      expect(node.width, 200);
      expect(node.height, 80);
    });

    test('copyWith updates fields', () {
      final node = MindNode(id: '1', mindId: 'm1', content: 'hello');
      final updated = node.copyWith(content: 'world', x: 100, y: 200);
      expect(updated.content, 'world');
      expect(updated.x, 100);
      expect(updated.y, 200);
      expect(updated.id, '1');
    });

    test('copyWith can change id', () {
      final node = MindNode(id: '1', mindId: 'm1');
      final updated = node.copyWith(id: '2');
      expect(updated.id, '2');
      expect(updated.mindId, 'm1');
    });

    test('copyWith handles tags', () {
      final node = MindNode(id: '1', mindId: 'm1');
      final updated = node.copyWith(tags: ['tag1', 'tag2']);
      expect(updated.tags, ['tag1', 'tag2']);
    });

    test('equality works', () {
      final a = MindNode(id: '1', mindId: 'm1', content: 'test', x: 10, y: 20);
      final b = MindNode(id: '1', mindId: 'm1', content: 'test', x: 10, y: 20);
      expect(a, equals(b));
    });

    test('inequality on different fields', () {
      final a = MindNode(id: '1', mindId: 'm1', content: 'test');
      final b = MindNode(id: '2', mindId: 'm1', content: 'test');
      expect(a, isNot(equals(b)));
    });

    test('toJson and fromJson round-trip', () {
      final node = MindNode(
        id: '1',
        mindId: 'm1',
        content: 'hello world',
        x: 150.5,
        y: 300.2,
        width: 250,
        height: 100,
        tags: ['important', 'draft'],
      );
      final json = node.toJson();
      final reconstructed = MindNode.fromJson(json);
      expect(reconstructed.id, node.id);
      expect(reconstructed.mindId, node.mindId);
      expect(reconstructed.content, node.content);
      expect(reconstructed.x, node.x);
      expect(reconstructed.y, node.y);
      expect(reconstructed.width, node.width);
      expect(reconstructed.height, node.height);
      expect(reconstructed.tags, ['important', 'draft']);
      expect(reconstructed.createdAt, isNotNull);
    });

    test('toJson omits empty tags', () {
      final node = MindNode(id: '1', mindId: 'm1', tags: []);
      final json = node.toJson();
      expect(json.containsKey('tags'), isFalse);
    });

    test('fromJson handles missing tags', () {
      final json = {
        'id': '1',
        'mindId': 'm1',
        'type': 'text',
        'content': 'hello',
        'x': 0,
        'y': 0,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final node = MindNode.fromJson(json);
      expect(node.tags, isEmpty);
    });

    test('fromJson handles missing width/height', () {
      final json = {
        'id': '1',
        'mindId': 'm1',
        'type': 'text',
        'content': 'hello',
        'x': 0,
        'y': 0,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final node = MindNode.fromJson(json);
      expect(node.width, 200);
      expect(node.height, 80);
    });

    test('toJson contains all keys', () {
      final node = MindNode(id: '1', mindId: 'm1');
      final json = node.toJson();
      expect(json, containsPair('id', '1'));
      expect(json, containsPair('mindId', 'm1'));
      expect(json, containsPair('type', 'text'));
    });

    test('copyWith changes type', () {
      final node = MindNode(id: '1', mindId: 'm1');
      final updated = node.copyWith(type: NodeType.task);
      expect(updated.type, NodeType.task);
      expect(updated.id, '1');
    });

    test('contentHeight returns minimum for empty node', () {
      final node = MindNode(id: '1', mindId: 'm1');
      expect(node.contentHeight, 40);
    });

    test('contentHeight accounts for content and tags', () {
      final node = MindNode(
        id: '1',
        mindId: 'm1',
        content: 'Hello world',
        tags: ['tag1'],
      );
      expect(node.contentHeight, greaterThan(60));
    });

    test('toJson includes type field', () {
      final node = MindNode(id: '1', mindId: 'm1', type: NodeType.task);
      final json = node.toJson();
      expect(json['type'], 'task');
    });

    test('fromJson handles unknown type gracefully', () {
      final json = {
        'id': '1',
        'mindId': 'm1',
        'type': 'unknown_future_type',
        'content': 'hello',
        'x': 0,
        'y': 0,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final node = MindNode.fromJson(json);
      expect(node.type, NodeType.text);
      expect(node.content, 'hello');
    });

    test('fromJson handles missing type gracefully', () {
      final json = {
        'id': '1',
        'mindId': 'm1',
        'content': 'hello',
        'x': 0,
        'y': 0,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-01T00:00:00.000',
      };
      final node = MindNode.fromJson(json);
      expect(node.type, NodeType.text);
    });

    test('fromJson throws on missing id', () {
      expect(
        () => MindNode.fromJson({
          'mindId': 'm1',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }),
        throwsArgumentError,
      );
    });

    test('fromJson throws on missing mindId', () {
      expect(
        () => MindNode.fromJson({
          'id': 'n1',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }),
        throwsArgumentError,
      );
    });

    test('fromJson handles malformed dates gracefully', () {
      final node = MindNode.fromJson({
        'id': 'n1',
        'mindId': 'm1',
        'createdAt': 'not-a-date',
        'updatedAt': 'not-a-date',
      });
      expect(node.createdAt, isA<DateTime>());
      expect(node.updatedAt, isA<DateTime>());
    });

    test('fromJson defaults missing optional fields', () {
      final node = MindNode.fromJson({
        'id': 'n1',
        'mindId': 'm1',
        'type': 'text',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      expect(node.content, '');
      expect(node.tags, isEmpty);
      expect(node.x, 0);
      expect(node.y, 0);
      expect(node.width, 200);
      expect(node.height, 80);
    });
  });
}
