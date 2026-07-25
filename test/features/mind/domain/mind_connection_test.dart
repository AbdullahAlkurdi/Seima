import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/mind/domain/mind_connection.dart';

void main() {
  group('MindConnection', () {
    test('creates with required fields', () {
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      expect(conn.id, 'c1');
      expect(conn.mindId, 'm1');
      expect(conn.sourceNodeId, 'n1');
      expect(conn.targetNodeId, 'n2');
    });

    test('equality works', () {
      final a = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      final b = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      expect(a, equals(b));
    });

    test('inequality on different id', () {
      final a = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      final b = MindConnection(
        id: 'c2',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      expect(a, isNot(equals(b)));
    });

    test('toJson and fromJson round-trip', () {
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      final json = conn.toJson();
      final reconstructed = MindConnection.fromJson(json);
      expect(reconstructed.id, conn.id);
      expect(reconstructed.mindId, conn.mindId);
      expect(reconstructed.sourceNodeId, conn.sourceNodeId);
      expect(reconstructed.targetNodeId, conn.targetNodeId);
    });

    test('toString shows connection arrow', () {
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      expect(conn.toString(), contains('n1 → n2'));
    });

    test('fromJson throws on missing id', () {
      expect(
        () => MindConnection.fromJson({
          'mindId': 'm1',
          'sourceNodeId': 'n1',
          'targetNodeId': 'n2',
        }),
        throwsArgumentError,
      );
    });

    test('fromJson throws on missing mindId', () {
      expect(
        () => MindConnection.fromJson({
          'id': 'c1',
          'sourceNodeId': 'n1',
          'targetNodeId': 'n2',
        }),
        throwsArgumentError,
      );
    });

    test('fromJson throws on missing sourceNodeId', () {
      expect(
        () => MindConnection.fromJson({
          'id': 'c1',
          'mindId': 'm1',
          'targetNodeId': 'n2',
        }),
        throwsArgumentError,
      );
    });

    test('fromJson throws on missing targetNodeId', () {
      expect(
        () => MindConnection.fromJson({
          'id': 'c1',
          'mindId': 'm1',
          'sourceNodeId': 'n1',
        }),
        throwsArgumentError,
      );
    });

    test('fromJson defaults missing createdAt to now', () {
      final conn = MindConnection.fromJson({
        'id': 'c1',
        'mindId': 'm1',
        'sourceNodeId': 'n1',
        'targetNodeId': 'n2',
      });
      expect(conn.createdAt, isA<DateTime>());
    });
  });
}
