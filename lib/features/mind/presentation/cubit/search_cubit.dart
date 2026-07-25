import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindora/core/errors/failures.dart';
import 'package:mindora/features/mind/data/mind_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final MindRepository repository;

  SearchCubit({required this.repository}) : super(const SearchState());

  void search(String query) {
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(state.copyWith(query: query, isSearching: true));
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final minds = await repository.loadAll();
      final lowerQuery = query.toLowerCase();
      final results = <SearchResult>[];

      for (final mind in minds) {
        if (mind.title.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(mind: mind, matchingText: mind.title));
        }
        for (final node in mind.nodes) {
          final contentMatch = node.content.toLowerCase().contains(lowerQuery);
          final matchedTags = node.tags
              .where((t) => t.toLowerCase().contains(lowerQuery))
              .toList();
          if (contentMatch || matchedTags.isNotEmpty) {
            results.add(
              SearchResult(
                mind: mind,
                nodeId: node.id,
                matchingText: node.content,
                matchingTags: matchedTags,
              ),
            );
          }
        }
      }

      emit(state.copyWith(results: results, isSearching: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSearching: false,
          error: Failure.unknown('Search failed'),
        ),
      );
    }
  }

  void clear() {
    emit(const SearchState());
  }
}
