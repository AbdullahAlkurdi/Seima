import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mindora/features/mind/data/mind_repository.dart';
import 'package:mindora/features/mind/domain/mind.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/presentation/cubit/search_cubit.dart';
import 'package:mindora/features/mind/presentation/cubit/search_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MindRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MindRepository();
  });

  group('SearchCubit', () {
    test('initial state has empty query and results', () {
      final cubit = SearchCubit(repository: repository);
      expect(cubit.state.query, '');
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.isSearching, isFalse);
    });

    blocTest<SearchCubit, SearchState>(
      'search with empty query clears results',
      build: () => SearchCubit(repository: repository),
      act: (cubit) {
        cubit.search('');
      },
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', '')
            .having((s) => s.results, 'results', isEmpty),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'search finds matching mind title',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        await repository.save(Mind(id: 'm1', title: 'My Project Ideas'));
        await repository.save(Mind(id: 'm2', title: 'Shopping List'));
        cubit.search('project');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 1);
        expect(cubit.state.results.first.mind.title, 'My Project Ideas');
        expect(cubit.state.results.first.nodeId, isNull);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'search finds matching node content',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        final mind = Mind(
          id: 'm1',
          title: 'Ideas',
          nodes: [
            MindNode(id: 'n1', mindId: 'm1', content: 'Build a great app'),
            MindNode(id: 'n2', mindId: 'm1', content: 'Learn Flutter'),
          ],
        );
        await repository.save(mind);
        cubit.search('Flutter');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 1);
        expect(cubit.state.results.first.mind.id, 'm1');
        expect(cubit.state.results.first.nodeId, 'n2');
        expect(cubit.state.results.first.matchingText, 'Learn Flutter');
      },
    );

    blocTest<SearchCubit, SearchState>(
      'search is case-insensitive',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        await repository.save(Mind(id: 'm1', title: 'DESIGN System'));
        cubit.search('design');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 1);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'search returns empty for no matches',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        await repository.save(Mind(id: 'm1', title: 'First'));
        cubit.search('nonexistent');
      },
      verify: (cubit) {
        expect(cubit.state.results, isEmpty);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'clear resets state',
      build: () => SearchCubit(repository: repository),
      act: (cubit) {
        cubit.clear();
      },
      expect: () => [const SearchState()],
    );

    blocTest<SearchCubit, SearchState>(
      'search finds matching tags on nodes',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        final mind = Mind(
          id: 'm1',
          title: 'Ideas',
          nodes: [
            MindNode(
              id: 'n1',
              mindId: 'm1',
              content: 'Build an app',
              tags: ['flutter', 'mobile'],
            ),
            MindNode(
              id: 'n2',
              mindId: 'm1',
              content: 'Learn something new',
              tags: ['rust', 'systems'],
            ),
          ],
        );
        await repository.save(mind);
        cubit.search('flutter');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 1);
        expect(cubit.state.results.first.matchingTags, contains('flutter'));
      },
    );

    blocTest<SearchCubit, SearchState>(
      'search finds node via tag match even without content match',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        final mind = Mind(
          id: 'm1',
          title: 'Ideas',
          nodes: [
            MindNode(
              id: 'n1',
              mindId: 'm1',
              content: 'Some content',
              tags: ['urgent', 'important'],
            ),
          ],
        );
        await repository.save(mind);
        cubit.search('urgent');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 1);
        expect(cubit.state.results.first.matchingText, 'Some content');
        expect(cubit.state.results.first.matchingTags, contains('urgent'));
      },
    );

    blocTest<SearchCubit, SearchState>(
      'search across multiple minds and nodes',
      build: () => SearchCubit(repository: repository),
      act: (cubit) async {
        await repository.save(
          Mind(
            id: 'm1',
            title: 'Work',
            nodes: [MindNode(id: 'n1', mindId: 'm1', content: 'Meeting notes')],
          ),
        );
        await repository.save(
          Mind(
            id: 'm2',
            title: 'Personal',
            nodes: [
              MindNode(id: 'n2', mindId: 'm2', content: 'Meeting with friend'),
            ],
          ),
        );
        cubit.search('meeting');
      },
      verify: (cubit) {
        expect(cubit.state.results.length, 2);
      },
    );
  });
}
