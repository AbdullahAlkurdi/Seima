import 'package:mindora/core/errors/failures.dart';
import 'package:mindora/features/mind/domain/mind.dart';

class MindState {
  final Mind? mind;
  final Set<String> selectedNodeIds;
  final String? selectedConnectionId;
  final String? connectionSourceNodeId;
  final bool isLoading;
  final bool isSaving;
  final Failure? error;
  final List<Mind> undoHistory;
  final List<Mind> redoHistory;

  const MindState({
    this.mind,
    this.selectedNodeIds = const {},
    this.selectedConnectionId,
    this.connectionSourceNodeId,
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.undoHistory = const [],
    this.redoHistory = const [],
  });

  bool get canUndo => undoHistory.isNotEmpty;
  bool get canRedo => redoHistory.isNotEmpty;

  MindState copyWith({
    Mind? mind,
    Set<String>? selectedNodeIds,
    bool clearSelection = false,
    String? selectedConnectionId,
    bool clearSelectedConnection = false,
    String? connectionSourceNodeId,
    bool clearConnectionSource = false,
    bool? isLoading,
    bool? isSaving,
    Failure? error,
    bool clearError = false,
    List<Mind>? undoHistory,
    List<Mind>? redoHistory,
  }) {
    return MindState(
      mind: mind ?? this.mind,
      selectedNodeIds: clearSelection
          ? const {}
          : selectedNodeIds ?? this.selectedNodeIds,
      selectedConnectionId: clearSelectedConnection
          ? null
          : selectedConnectionId ?? this.selectedConnectionId,
      connectionSourceNodeId: clearConnectionSource
          ? null
          : connectionSourceNodeId ?? this.connectionSourceNodeId,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
    );
  }

  MindState updateMind(Mind updatedMind) {
    final nextMind = updatedMind.copyWith(
      sequenceNumber: updatedMind.sequenceNumber + 1,
    );
    final validIds = nextMind.nodes.map((n) => n.id).toSet();
    final filteredSelection = selectedNodeIds.where(validIds.contains).toSet();
    final connSourceExists = nextMind.nodes.any(
      (n) => n.id == connectionSourceNodeId,
    );
    final connStillExists =
        selectedConnectionId != null &&
        nextMind.connections.any((c) => c.id == selectedConnectionId);
    if (!connStillExists && selectedConnectionId != null) {
      return copyWith(
        mind: nextMind,
        selectedNodeIds: filteredSelection,
        clearConnectionSource: !connSourceExists,
        clearSelectedConnection: true,
      );
    }
    return copyWith(
      mind: nextMind,
      selectedNodeIds: filteredSelection,
      clearConnectionSource: !connSourceExists,
    );
  }

  MindState pushUndo(Mind previousMind) {
    return copyWith(
      undoHistory: [previousMind, ...undoHistory].take(50).toList(),
      redoHistory: const [],
    );
  }
}
