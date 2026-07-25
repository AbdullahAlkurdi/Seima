import 'package:equatable/equatable.dart';
import 'package:seima/core/errors/failures.dart';
import 'package:seima/features/mind/domain/mind.dart';

class SearchResult extends Equatable {
  final Mind mind;
  final String? nodeId;
  final String? matchingText;
  final List<String> matchingTags;

  const SearchResult({
    required this.mind,
    this.nodeId,
    this.matchingText,
    this.matchingTags = const [],
  });

  @override
  List<Object?> get props => [mind.id, nodeId, matchingText, matchingTags];
}

class SearchState extends Equatable {
  final String query;
  final List<SearchResult> results;
  final bool isSearching;
  final Failure? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isSearching,
    bool clearError = false,
    Failure? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [query, results, isSearching, error];
}
