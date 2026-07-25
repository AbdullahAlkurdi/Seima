import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/core/errors/app_exception.dart';
import 'package:mindora/features/mind/data/mind_repository.dart';
import 'package:mindora/features/mind/domain/mind.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/domain/mind_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MindRepository', () {
    late MindRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = MindRepository();
    });

    test('loadAll returns empty list when no minds saved', () async {
      final minds = await repository.loadAll();
      expect(minds, isEmpty);
    });

    test('save and load round-trip', () async {
      final mind = Mind(id: 'm1', title: 'Test');
      await repository.save(mind);
      final loaded = await repository.load('m1');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'm1');
      expect(loaded.title, 'Test');
    });

    test('updateLastAccessed updates timestamp', () async {
      final mind = Mind(id: 'm1', title: 'Test');
      await repository.save(mind);
      await Future.delayed(const Duration(milliseconds: 1));
      await repository.updateLastAccessed('m1');
      final loaded = await repository.load('m1');
      expect(loaded!.lastAccessedAt.isAfter(mind.lastAccessedAt), isTrue);
    });

    test('loadAll returns all saved minds', () async {
      await repository.save(Mind(id: 'm1', title: 'First'));
      await repository.save(Mind(id: 'm2', title: 'Second'));
      final minds = await repository.loadAll();
      expect(minds.length, 2);
    });

    test('save updates existing mind', () async {
      await repository.save(Mind(id: 'm1', title: 'Original'));
      await repository.save(Mind(id: 'm1', title: 'Updated'));
      final mind = await repository.load('m1');
      expect(mind!.title, 'Updated');
      final minds = await repository.loadAll();
      expect(minds.length, 1);
    });

    test('delete removes mind', () async {
      await repository.save(Mind(id: 'm1', title: 'Test'));
      await repository.delete('m1');
      final mind = await repository.load('m1');
      expect(mind, isNull);
    });

    test('delete nonexistent mind does not error', () async {
      await repository.save(Mind(id: 'm1', title: 'Test'));
      await repository.delete('nonexistent');
      final minds = await repository.loadAll();
      expect(minds.length, 1);
    });

    test('load returns null for nonexistent id', () async {
      final mind = await repository.load('nonexistent');
      expect(mind, isNull);
    });

    test('loadAll handles corrupted storage gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('minds', 'not valid json');
      expect(() => repository.loadAll(), throwsA(isA<AppException>()));
    });

    test('loadAll restores from backup when primary corrupted', () async {
      final mind1 = Mind(id: 'm1', title: 'Backup Test');
      await repository.save(mind1);
      final mind2 = Mind(id: 'm2', title: 'Second');
      await repository.save(mind2);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('minds', 'corrupted');
      final minds = await repository.loadAll();
      expect(minds.length, 1);
      expect(minds.first.id, 'm1');
    });

    test('loadAll handles empty storage', () async {
      final minds = await repository.loadAll();
      expect(minds, isEmpty);
    });

    test('loadAll handles missing id fields gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode([
        {
          'id': 'm1',
          'title': 'Valid',
          'nodes': [],
          'connections': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {'no_id': 'm2', 'title': 'Invalid'},
        {'id': null, 'title': 'Null id'},
      ]);
      await prefs.setString('minds', data);
      final minds = await repository.loadAll();
      expect(minds.length, 1);
      expect(minds.first.id, 'm1');
    });

    test('loadAll handles missing createdAt gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode([
        {'id': 'm1', 'title': 'No Dates', 'nodes': [], 'connections': []},
      ]);
      await prefs.setString('minds', data);
      final minds = await repository.loadAll();
      expect(minds.length, 1);
    });

    test('duplicate creates a copy with new id', () async {
      final node = MindNode(id: 'n1', mindId: 'm1', content: 'hello');
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      await repository.save(
        Mind(id: 'm1', title: 'Original', nodes: [node], connections: [conn]),
      );
      final copy = await repository.duplicate('m1');

      expect(copy.id, isNot('m1'));
      expect(copy.title, 'Original (Copy)');
      expect(copy.nodes.length, 1);
      expect(copy.nodes.first.id, isNot('n1'));
      expect(copy.nodes.first.content, 'hello');
      expect(copy.connections.length, 1);
      expect(copy.connections.first.id, isNot('c1'));

      final minds = await repository.loadAll();
      expect(minds.length, 2);
    });

    test('duplicate with connections remaps source/target', () async {
      final node1 = MindNode(id: 'n1', mindId: 'm1', content: 'A');
      final node2 = MindNode(id: 'n2', mindId: 'm1', content: 'B');
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      await repository.save(
        Mind(
          id: 'm1',
          title: 'Original',
          nodes: [node1, node2],
          connections: [conn],
        ),
      );
      final copy = await repository.duplicate('m1');
      expect(copy.nodes.length, 2);
      expect(copy.connections.length, 1);
    });

    test('persistence across reload', () async {
      await repository.save(Mind(id: 'm1', title: 'Stays'));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('minds');
      expect(raw, isNotNull);

      SharedPreferences.setMockInitialValues({'minds': raw!});
      final repo2 = MindRepository();
      final minds = await repo2.loadAll();
      expect(minds.length, 1);
      expect(minds.first.title, 'Stays');
    });

    test('loadAll handles malformed json gracefully', () async {
      SharedPreferences.setMockInitialValues({'minds': 'not valid json'});
      final repo = MindRepository();
      expect(() => repo.loadAll(), throwsA(isA<Exception>()));
    });

    test('loadAll returns empty for non-existent key', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = MindRepository();
      final minds = await repo.loadAll();
      expect(minds, isEmpty);
    });

    test('delete one mind does not affect others', () async {
      await repository.save(Mind(id: 'm1', title: 'Mind 1'));
      await repository.save(Mind(id: 'm2', title: 'Mind 2'));
      await repository.delete('m1');
      final minds = await repository.loadAll();
      expect(minds.length, 1);
      expect(minds.first.id, 'm2');
    });
  });
}
