import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seima/core/errors/failures.dart';
import 'package:seima/features/mind/data/id_provider.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/domain/node_type.dart';
import 'mind_state.dart';

class MindCubit extends Cubit<MindState> {
  final MindRepository repository;
  Timer? _autoSaveTimer;
  Timer? _moveUndoTimer;
  bool _isDragging = false;
  Mind? _preDragMind;
  bool _saveInProgress = false;
  bool _isBatchingUndo = false;
  Mind? _batchPreState;

  MindCubit({required this.repository}) : super(const MindState());

  bool get isDragging => _isDragging;

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    _moveUndoTimer?.cancel();
    return super.close();
  }

  Future<void> loadMostRecent() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final minds = await repository.loadAll();
      if (minds.isNotEmpty) {
        final mind = await repository.load(minds.first.id);
        emit(state.copyWith(mind: mind ?? minds.first, isLoading: false));
      } else {
        await _createNew();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Failure.unknown('Failed to load mind'),
        ),
      );
    }
  }

  Future<void> loadMind(String id) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final mind = await repository.load(id);
      if (mind != null) {
        emit(state.copyWith(mind: mind, isLoading: false));
      } else {
        await _createNew();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Failure.unknown('Failed to load mind'),
        ),
      );
    }
  }

  Future<void> _createNew() async {
    final mind = Mind(id: generateId(), title: 'My Mind');
    try {
      await repository.save(mind);
      emit(state.copyWith(mind: mind, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          mind: mind,
          error: Failure.unknown('Failed to create new mind'),
        ),
      );
    }
  }

  void createNode(double x, double y) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final node = MindNode(id: generateId(), mindId: mind.id, x: x, y: y);
    final updatedMind = mind.copyWith(nodes: [...mind.nodes, node]);
    emit(state.updateMind(updatedMind));
    _autoSave();
  }

  void updateNodeContent(String nodeId, String content) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final nodes = mind.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(content: content);
      return n;
    }).toList();
    emit(state.updateMind(mind.copyWith(nodes: nodes)));
  }

  void updateNodeTags(String nodeId, List<String> tags) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final nodes = mind.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(tags: tags);
      return n;
    }).toList();
    emit(state.updateMind(mind.copyWith(nodes: nodes)));
    _autoSave();
  }

  void beginNodeDrag() {
    _isDragging = true;
    _moveUndoTimer?.cancel();
    _preDragMind = state.mind;
  }

  void endNodeDrag() {
    _isDragging = false;
    _moveUndoTimer?.cancel();
    if (_preDragMind != null) {
      emit(state.pushUndo(_preDragMind!));
      _preDragMind = null;
    }
    _autoSave();
  }

  void beginBatchUndo() {
    _isBatchingUndo = true;
    _batchPreState = state.mind;
  }

  void endBatchUndo() {
    _isBatchingUndo = false;
    if (_batchPreState != null) {
      emit(state.pushUndo(_batchPreState!));
      _batchPreState = null;
    }
    _autoSave();
  }

  void moveNode(String nodeId, double x, double y) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isDragging) {
      emit(state.pushUndo(mind));
    }
    final nodes = mind.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(x: x, y: y);
      return n;
    }).toList();
    emit(state.updateMind(mind.copyWith(nodes: nodes)));
    if (!_isDragging) {
      _autoSave();
    }
  }

  void deleteNode(String nodeId) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final nodes = mind.nodes.where((n) => n.id != nodeId).toList();
    final connections = mind.connections
        .where((c) => c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
        .toList();
    emit(
      state.updateMind(mind.copyWith(nodes: nodes, connections: connections)),
    );
    _autoSave();
  }

  void selectNode(String? nodeId) {
    if (nodeId == null) {
      emit(state.copyWith(clearSelection: true));
    } else {
      emit(state.copyWith(selectedNodeIds: {nodeId}));
    }
  }

  void toggleNodeSelection(String nodeId) {
    final current = state.selectedNodeIds;
    if (current.contains(nodeId)) {
      final updated = Set<String>.from(current)..remove(nodeId);
      emit(state.copyWith(selectedNodeIds: updated));
    } else {
      final updated = Set<String>.from(current)..add(nodeId);
      emit(state.copyWith(selectedNodeIds: updated));
    }
  }

  void selectAll() {
    final mind = state.mind;
    if (mind == null) return;
    emit(state.copyWith(selectedNodeIds: mind.nodes.map((n) => n.id).toSet()));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }

  void moveSelectedNodes(double dx, double dy) {
    final mind = state.mind;
    if (mind == null || state.selectedNodeIds.isEmpty) return;
    if (!_isDragging) {
      emit(state.pushUndo(mind));
    }
    final nodes = mind.nodes.map((n) {
      if (state.selectedNodeIds.contains(n.id)) {
        return n.copyWith(x: n.x + dx, y: n.y + dy);
      }
      return n;
    }).toList();
    emit(state.updateMind(mind.copyWith(nodes: nodes)));
    if (!_isDragging) {
      _autoSave();
    }
  }

  void deleteSelectedNodes() {
    final mind = state.mind;
    if (mind == null || state.selectedNodeIds.isEmpty) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final ids = state.selectedNodeIds;
    final nodes = mind.nodes.where((n) => !ids.contains(n.id)).toList();
    final connections = mind.connections
        .where(
          (c) => !ids.contains(c.sourceNodeId) && !ids.contains(c.targetNodeId),
        )
        .toList();
    emit(
      state.updateMind(mind.copyWith(nodes: nodes, connections: connections)),
    );
    _autoSave();
  }

  void startConnection(String nodeId) {
    emit(
      state.copyWith(
        connectionSourceNodeId: nodeId,
        clearConnectionSource: false,
      ),
    );
  }

  void completeConnection(String targetNodeId) {
    final sourceId = state.connectionSourceNodeId;
    final mind = state.mind;
    if (sourceId == null || mind == null || sourceId == targetNodeId) {
      emit(state.copyWith(clearConnectionSource: true));
      return;
    }
    final exists = mind.connections.any(
      (c) =>
          (c.sourceNodeId == sourceId && c.targetNodeId == targetNodeId) ||
          (c.sourceNodeId == targetNodeId && c.targetNodeId == sourceId),
    );
    if (exists) {
      emit(state.copyWith(clearConnectionSource: true));
      return;
    }
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final connection = MindConnection(
      id: generateId(),
      mindId: mind.id,
      sourceNodeId: sourceId,
      targetNodeId: targetNodeId,
    );
    final updatedMind = mind.copyWith(
      connections: [...mind.connections, connection],
    );
    emit(state.updateMind(updatedMind).copyWith(clearConnectionSource: true));
    _autoSave();
  }

  void changeNodeType(String nodeId, NodeType type) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    final nodes = mind.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(type: type);
      return n;
    }).toList();
    emit(state.updateMind(mind.copyWith(nodes: nodes)));
    _autoSave();
  }

  void selectConnection(String? connectionId) {
    emit(
      state.copyWith(
        selectedConnectionId: connectionId,
        clearSelection: connectionId != null,
      ),
    );
  }

  void onConnectionTap(String connectionId) {
    selectConnection(connectionId);
  }

  void onCanvasTap() {
    emit(
      state.copyWith(
        clearSelection: true,
        clearSelectedConnection: true,
        clearConnectionSource: false,
      ),
    );
  }

  void cancelConnection() {
    emit(state.copyWith(clearConnectionSource: true));
  }

  void deleteConnection(String connectionId) {
    final mind = state.mind;
    if (mind == null) return;
    emit(state.pushUndo(mind));
    final connections = mind.connections
        .where((c) => c.id != connectionId)
        .toList();
    emit(state.updateMind(mind.copyWith(connections: connections)));
    _autoSave();
  }

  void undo() {
    if (!state.canUndo || state.mind == null) return;
    final currentMind = state.mind!;
    final previousMind = state.undoHistory.first;
    emit(
      state.copyWith(
        mind: previousMind,
        undoHistory: state.undoHistory.sublist(1),
        redoHistory: [currentMind, ...state.redoHistory],
      ),
    );
    _autoSave();
  }

  void redo() {
    if (!state.canRedo || state.mind == null) return;
    final currentMind = state.mind!;
    final nextMind = state.redoHistory.first;
    emit(
      state.copyWith(
        mind: nextMind,
        undoHistory: [currentMind, ...state.undoHistory],
        redoHistory: state.redoHistory.sublist(1),
      ),
    );
    _autoSave();
  }

  Future<void> save() async {
    if (state.mind == null || _saveInProgress) return;
    _saveInProgress = true;
    if (isClosed) {
      _saveInProgress = false;
      return;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await repository.save(state.mind!);
      if (!isClosed) {
        emit(state.copyWith(isSaving: false));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            error: Failure.unknown('Failed to save mind'),
          ),
        );
      }
    } finally {
      _saveInProgress = false;
    }
  }

  void updateTitle(String title) {
    final mind = state.mind;
    if (mind == null) return;
    if (!_isBatchingUndo) emit(state.pushUndo(mind));
    emit(state.updateMind(mind.copyWith(title: title, updateTimestamp: true)));
    _autoSave();
  }

  Map<String, dynamic> exportMind() {
    if (state.mind == null) return {};
    return {
      'version': 1,
      'mind': state.mind!.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importMind(Map<String, dynamic> data) async {
    try {
      final mindJson = data['mind'] as Map<String, dynamic>;
      final mind = Mind.fromJson(mindJson);
      _validateConnections(mind);
      await repository.save(mind);
      if (!_isBatchingUndo) emit(state.pushUndo(state.mind ?? mind));
      emit(state.updateMind(mind));
    } catch (e) {
      emit(
        state.copyWith(
          error: e is Failure ? e : Failure.unknown('Failed to import mind'),
        ),
      );
    }
  }

  void _validateConnections(Mind mind) {
    final nodeIds = mind.nodes.map((n) => n.id).toSet();
    for (final conn in mind.connections) {
      if (!nodeIds.contains(conn.sourceNodeId)) {
        throw Failure.unknown(
          'Invalid import: connection references non-existent source node "${conn.sourceNodeId}"',
        );
      }
      if (!nodeIds.contains(conn.targetNodeId)) {
        throw Failure.unknown(
          'Invalid import: connection references non-existent target node "${conn.targetNodeId}"',
        );
      }
    }
  }

  Future<void> deleteMind(String id) async {
    try {
      await repository.delete(id);
      if (state.mind?.id == id) {
        emit(state.copyWith(mind: null));
      }
    } catch (e) {
      emit(
        state.copyWith(
          error: Failure.unknown('Failed to delete mind'),
        ),
      );
    }
  }

  void _autoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 300), () {
      save();
    });
  }
}
