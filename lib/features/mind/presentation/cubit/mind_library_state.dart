import 'package:mindora/core/errors/failures.dart';
import 'package:mindora/features/mind/domain/mind.dart';

class MindLibraryState {
  final List<Mind> minds;
  final bool isLoading;
  final Failure? error;

  const MindLibraryState({
    this.minds = const [],
    this.isLoading = true,
    this.error,
  });

  MindLibraryState copyWith({
    List<Mind>? minds,
    bool? isLoading,
    bool clearError = false,
    Failure? error,
  }) {
    return MindLibraryState(
      minds: minds ?? this.minds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
