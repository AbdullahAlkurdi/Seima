import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seima/features/sharing/domain/sharing_failure.dart';
import 'package:seima/features/sharing/data/import_service.dart';
import 'package:seima/features/sharing/presentation/cubit/import_state.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/data/mind_repository.dart';

class ImportCubit extends Cubit<ImportState> {
  final ImportService _importService;
  final MindRepository _repository;

  ImportCubit({
    required ImportService importService,
    required MindRepository repository,
  }) : _importService = importService,
       _repository = repository,
       super(const ImportState());

  void setPendingContent(String content, {String? source}) {
    emit(state.copyWith(pendingContent: content, pendingSource: source));
  }

  Future<void> previewPendingContent() async {
    final content = state.pendingContent;
    if (content == null) return;
    await previewFromString(content, sourceHint: state.pendingSource);
  }

  Future<void> previewFromString(String input, {String? sourceHint}) async {
    emit(state.copyWith(step: ImportStep.loading, clearPending: true));
    try {
      final preview = await _importService.previewFromString(
        input,
        sourceHint: sourceHint,
      );
      emit(state.copyWith(step: ImportStep.preview, preview: preview));
    } on SharingFailure catch (e) {
      emit(state.copyWith(step: ImportStep.failure, failure: e));
    } catch (e) {
      emit(
        state.copyWith(
          step: ImportStep.failure,
          failure: SharingFailure.unknown('$e'),
        ),
      );
    }
  }

  Future<void> previewFromFile(String path) async {
    emit(state.copyWith(step: ImportStep.loading));
    try {
      final preview = await _importService.previewFromFile(path);
      emit(state.copyWith(step: ImportStep.preview, preview: preview));
    } on SharingFailure catch (e) {
      emit(state.copyWith(step: ImportStep.failure, failure: e));
    } catch (e) {
      emit(
        state.copyWith(
          step: ImportStep.failure,
          failure: SharingFailure.unknown('$e'),
        ),
      );
    }
  }

  Future<Mind?> executeAsNewMind() async {
    final preview = state.preview;
    if (preview == null) return null;
    emit(state.copyWith(step: ImportStep.executing));
    try {
      final result = await _importService.executeAsNewMind(preview);
      await _repository.save(result.mind);
      emit(state.copyWith(step: ImportStep.success, result: result));
      return result.mind;
    } on SharingFailure catch (e) {
      emit(state.copyWith(step: ImportStep.failure, failure: e));
      return null;
    } catch (e) {
      emit(
        state.copyWith(
          step: ImportStep.failure,
          failure: SharingFailure.unknown('$e'),
        ),
      );
      return null;
    }
  }

  Future<Mind?> executeMergeIntoMind(Mind targetMind) async {
    final preview = state.preview;
    if (preview == null) return null;
    emit(state.copyWith(step: ImportStep.executing));
    try {
      final result = await _importService.executeMergeIntoMind(
        preview,
        targetMind,
      );
      await _repository.save(result.mind);
      emit(state.copyWith(step: ImportStep.success, result: result));
      return result.mind;
    } on SharingFailure catch (e) {
      emit(state.copyWith(step: ImportStep.failure, failure: e));
      return null;
    } catch (e) {
      emit(
        state.copyWith(
          step: ImportStep.failure,
          failure: SharingFailure.unknown('$e'),
        ),
      );
      return null;
    }
  }

  void reset() {
    emit(const ImportState());
  }
}
