import 'package:seima/features/sharing/domain/sharing_failure.dart';
import 'package:seima/features/sharing/data/import_service.dart';

enum ImportStep { initial, loading, preview, executing, success, failure }

class ImportState {
  final ImportStep step;
  final ImportPreview? preview;
  final ImportResult? result;
  final SharingFailure? failure;
  final String? pendingContent;
  final String? pendingSource;

  const ImportState({
    this.step = ImportStep.initial,
    this.preview,
    this.result,
    this.failure,
    this.pendingContent,
    this.pendingSource,
  });

  ImportState copyWith({
    ImportStep? step,
    ImportPreview? preview,
    ImportResult? result,
    SharingFailure? failure,
    String? pendingContent,
    bool clearPending = false,
    String? pendingSource,
  }) {
    return ImportState(
      step: step ?? this.step,
      preview: preview ?? this.preview,
      result: result ?? this.result,
      failure: clearPending ? null : (failure ?? this.failure),
      pendingContent: clearPending
          ? null
          : (pendingContent ?? this.pendingContent),
      pendingSource: clearPending
          ? null
          : (pendingSource ?? this.pendingSource),
    );
  }
}
