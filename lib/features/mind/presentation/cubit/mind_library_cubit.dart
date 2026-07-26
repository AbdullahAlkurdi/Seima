import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seima/core/errors/failures.dart';
import 'package:seima/features/mind/data/id_provider.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'mind_library_state.dart';

class MindLibraryCubit extends Cubit<MindLibraryState> {
  final MindRepository repository;

  MindLibraryCubit({required this.repository})
    : super(const MindLibraryState());

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final minds = await repository.loadAll();
      minds.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
      emit(state.copyWith(minds: minds, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: Failure.unknown('Failed to load minds'),
        ),
      );
    }
  }

  Future<Mind?> create({String title = 'My Mind', String? category}) async {
    try {
      final mind = Mind(id: generateId(), title: title, category: category);
      await repository.save(mind);
      final minds = [...state.minds, mind];
      emit(state.copyWith(minds: minds));
      return mind;
    } catch (e) {
      emit(state.copyWith(error: Failure.unknown('Failed to create mind')));
      return null;
    }
  }

  Future<void> rename(String id, String title) async {
    try {
      final minds = state.minds.map((m) {
        if (m.id == id) return m.copyWith(title: title, updateTimestamp: true);
        return m;
      }).toList();
      final updated = minds.firstWhere((m) => m.id == id);
      await repository.save(updated);
      emit(state.copyWith(minds: minds));
    } catch (e) {
      emit(state.copyWith(error: Failure.unknown('Failed to rename mind')));
    }
  }

  Future<void> delete(String id) async {
    try {
      await repository.delete(id);
      final minds = state.minds.where((m) => m.id != id).toList();
      emit(state.copyWith(minds: minds));
    } catch (e) {
      emit(state.copyWith(error: Failure.unknown('Failed to delete mind')));
    }
  }

  Future<void> clearAll() async {
    try {
      await repository.deleteAll();
      emit(state.copyWith(minds: []));
    } catch (e) {
      emit(state.copyWith(error: Failure.unknown('Failed to clear all data')));
    }
  }

  Future<void> duplicate(String id) async {
    try {
      final copy = await repository.duplicate(id);
      final minds = [copy, ...state.minds];
      emit(state.copyWith(minds: minds));
    } catch (e) {
      emit(state.copyWith(error: Failure.unknown('Failed to duplicate mind')));
    }
  }
}
