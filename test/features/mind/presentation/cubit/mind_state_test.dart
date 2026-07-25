import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/presentation/cubit/mind_state.dart';

void main() {
  group('MindState', () {
    test('initial state has correct defaults', () {
      final state = const MindState();
      expect(state.isLoading, isTrue);
      expect(state.isSaving, isFalse);
      expect(state.mind, isNull);
      expect(state.selectedNodeIds, isEmpty);
      expect(state.selectedConnectionId, isNull);
      expect(state.connectionSourceNodeId, isNull);
      expect(state.error, isNull);
      expect(state.canUndo, isFalse);
      expect(state.canRedo, isFalse);
      expect(state.undoHistory, isEmpty);
      expect(state.redoHistory, isEmpty);
    });

    test('copyWith updates fields', () {
      final state = const MindState();
      final mind = Mind(id: 'm1');
      final updated = state.copyWith(
        mind: mind,
        isLoading: false,
        isSaving: true,
      );
      expect(updated.mind, mind);
      expect(updated.isLoading, isFalse);
      expect(updated.isSaving, isTrue);
    });

    test('updateMind clears invalid selections', () {
      final state = const MindState(
        mind: null,
        selectedNodeIds: {'n1'},
        connectionSourceNodeId: 'n1',
      );

      final emptyMind = Mind(id: 'm1');
      final updated = state.updateMind(emptyMind);
      expect(updated.selectedNodeIds, isEmpty);
      expect(updated.connectionSourceNodeId, isNull);
    });

    test('updateMind preserves valid selections', () {
      final node = MindNode(id: 'n1', mindId: 'm1');
      final mind = Mind(id: 'm1', nodes: [node]);
      final state = const MindState(
        mind: null,
        selectedNodeIds: {'n1'},
        connectionSourceNodeId: 'n1',
      );
      final updated = state.updateMind(mind);
      expect(updated.selectedNodeIds, contains('n1'));
      expect(updated.connectionSourceNodeId, 'n1');
    });

    test('copyWith clearSelection clears selectedNodeIds', () {
      final state = const MindState(selectedNodeIds: {'n1'});
      final updated = state.copyWith(clearSelection: true);
      expect(updated.selectedNodeIds, isEmpty);
    });

    test('copyWith clearError clears error', () {
      final state = const MindState();
      final withError = state.copyWith(error: null, clearError: true);
      expect(withError.error, isNull);
    });

    test('pushUndo adds to history and clears redo', () {
      final mind1 = Mind(id: 'm1', title: 'Before');
      final state = const MindState().copyWith(mind: mind1, isLoading: false);
      final mind2 = Mind(id: 'm1', title: 'After');
      final pushed = state.pushUndo(mind2);
      expect(pushed.undoHistory.length, 1);
      expect(pushed.undoHistory.first.title, 'After');
      expect(pushed.redoHistory, isEmpty);
    });

    test('pushUndo caps history at 50', () {
      final mind = Mind(id: 'm1');
      var state = const MindState().copyWith(mind: mind, isLoading: false);
      for (int i = 0; i < 60; i++) {
        state = state.pushUndo(mind);
      }
      expect(state.undoHistory.length, 50);
    });

    test('canUndo returns correct value', () {
      final empty = const MindState();
      expect(empty.canUndo, isFalse);

      final withHistory = empty.copyWith(undoHistory: [Mind(id: 'm1')]);
      expect(withHistory.canUndo, isTrue);
    });

    test('canRedo returns correct value', () {
      final empty = const MindState();
      expect(empty.canRedo, isFalse);

      final withHistory = empty.copyWith(redoHistory: [Mind(id: 'm1')]);
      expect(withHistory.canRedo, isTrue);
    });

    test('copyWith sets selectedConnectionId', () {
      final state = const MindState().copyWith(selectedConnectionId: 'c1');
      expect(state.selectedConnectionId, 'c1');
    });

    test('copyWith clearSelectedConnection clears connection', () {
      final state = const MindState(
        selectedConnectionId: 'c1',
      ).copyWith(clearSelectedConnection: true);
      expect(state.selectedConnectionId, isNull);
    });

    test('updateMind clears invalid connection selection', () {
      final state = const MindState(
        selectedConnectionId: 'c1',
      ).updateMind(Mind(id: 'm1', title: 'No connections'));
      expect(state.selectedConnectionId, isNull);
    });

    test('updateMind preserves valid connection selection', () {
      final conn = MindConnection(
        id: 'c1',
        mindId: 'm1',
        sourceNodeId: 'n1',
        targetNodeId: 'n2',
      );
      final mind = Mind(
        id: 'm1',
        title: 'Has connections',
        nodes: [
          MindNode(id: 'n1', mindId: 'm1'),
          MindNode(id: 'n2', mindId: 'm1'),
        ],
        connections: [conn],
      );
      final state = const MindState(
        selectedConnectionId: 'c1',
      ).updateMind(mind);
      expect(state.selectedConnectionId, 'c1');
    });
  });
}
