import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mindora/features/mind/data/mind_repository.dart';
import 'package:mindora/features/mind/domain/mind.dart';
import 'package:mindora/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:mindora/features/mind/presentation/cubit/mind_library_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MindRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MindRepository();
  });

  group('MindLibraryCubit', () {
    test('initial state is loading with empty minds', () {
      final cubit = MindLibraryCubit(repository: repository);
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.minds, isEmpty);
    });

    blocTest<MindLibraryCubit, MindLibraryState>(
      'loadAll returns empty list when no minds',
      build: () => MindLibraryCubit(repository: repository),
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<MindLibraryState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MindLibraryState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.minds.length, 'minds empty', 0),
      ],
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'loadAll returns saved minds',
      build: () => MindLibraryCubit(repository: repository),
      act: (cubit) async {
        await repository.save(Mind(id: 'm1', title: 'First'));
        await repository.save(Mind(id: 'm2', title: 'Second'));
        await cubit.loadAll();
      },
      verify: (cubit) {
        expect(cubit.state.minds.length, 2);
        expect(cubit.state.minds.map((m) => m.title), contains('First'));
        expect(cubit.state.minds.map((m) => m.title), contains('Second'));
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'create adds a new mind to the list',
      build: () => MindLibraryCubit(repository: repository),
      act: (cubit) async {
        await cubit.loadAll();
        await cubit.create();
      },
      verify: (cubit) {
        expect(cubit.state.minds.length, 1);
        expect(cubit.state.minds.first.title, 'My Mind');
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'create persists across loadAll',
      build: () => MindLibraryCubit(repository: repository),
      seed: () => const MindLibraryState(isLoading: false),
      act: (cubit) async {
        await cubit.create();
        await cubit.loadAll();
      },
      verify: (cubit) {
        expect(cubit.state.minds.length, 1);
      },
    );

    test('rename updates mind title', () async {
      final cubit = MindLibraryCubit(repository: repository);
      expect(cubit.state.minds, isEmpty);
      await cubit.create();
      expect(cubit.state.minds.length, 1);
      final id = cubit.state.minds.first.id;
      expect(cubit.state.minds.first.title, 'My Mind');
      await cubit.rename(id, 'Renamed');
      expect(cubit.state.minds.length, 1);
      expect(cubit.state.minds.first.title, 'Renamed');
      await cubit.close();
    });

    test('rename works on existing mind in repo', () async {
      final existingMind = Mind(id: 'existing-id', title: 'Existing');
      await repository.save(existingMind);
      final cubit = MindLibraryCubit(repository: repository);

      await cubit.loadAll();
      expect(cubit.state.minds.first.title, 'Existing');

      // Check that copyWith works on the mind from state
      final mindFromState = cubit.state.minds.first;
      final copy = mindFromState.copyWith(title: 'DirectTest');
      expect(
        copy.title,
        'DirectTest',
        reason: 'copyWith on a state mind should work',
      );

      await cubit.rename('existing-id', 'Renamed');

      expect(
        cubit.state.minds.length,
        greaterThan(0),
        reason: 'State should still have minds',
      );
      expect(
        cubit.state.minds.first.id,
        'existing-id',
        reason: 'Mind id should be unchanged',
      );
      expect(
        cubit.state.minds.first.title,
        'Renamed',
        reason: 'Mind title should be updated',
      );

      final loaded = await repository.load('existing-id');
      expect(loaded, isNotNull);
      expect(loaded!.title, 'Renamed');

      await cubit.close();
    });

    blocTest<MindLibraryCubit, MindLibraryState>(
      'rename persists',
      build: () => MindLibraryCubit(repository: repository),
      seed: () => const MindLibraryState(isLoading: false),
      act: (cubit) async {
        await cubit.create();
        final id = cubit.state.minds.first.id;
        await cubit.rename(id, 'Persisted');
        await cubit.loadAll();
      },
      verify: (cubit) {
        expect(cubit.state.minds.first.title, 'Persisted');
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'delete removes mind from list',
      build: () => MindLibraryCubit(repository: repository),
      seed: () => const MindLibraryState(isLoading: false),
      act: (cubit) async {
        await cubit.create();
        await cubit.delete(cubit.state.minds.first.id);
      },
      verify: (cubit) {
        expect(cubit.state.minds, isEmpty);
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'delete persists',
      build: () => MindLibraryCubit(repository: repository),
      seed: () => const MindLibraryState(isLoading: false),
      act: (cubit) async {
        await cubit.create();
        await cubit.delete(cubit.state.minds.first.id);
        await cubit.loadAll();
      },
      verify: (cubit) {
        expect(cubit.state.minds, isEmpty);
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'duplicate creates a copy in list',
      build: () => MindLibraryCubit(repository: repository),
      seed: () => const MindLibraryState(isLoading: false),
      act: (cubit) async {
        await cubit.create();
        await cubit.duplicate(cubit.state.minds.first.id);
      },
      verify: (cubit) {
        expect(cubit.state.minds.length, 2);
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'loadAll sorts by lastAccessedAt descending',
      build: () => MindLibraryCubit(repository: repository),
      act: (cubit) async {
        await repository.save(Mind(id: 'old', title: 'Old'));
        await Future.delayed(const Duration(milliseconds: 1));
        await repository.save(Mind(id: 'new', title: 'New'));
        await cubit.loadAll();
      },
      verify: (cubit) {
        expect(cubit.state.minds.first.id, 'new');
      },
    );

    blocTest<MindLibraryCubit, MindLibraryState>(
      'error on loadAll does not crash',
      build: () {
        SharedPreferences.setMockInitialValues({'minds': 'broken json'});
        return MindLibraryCubit(repository: MindRepository());
      },
      act: (cubit) => cubit.loadAll(),
      verify: (cubit) {
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.error, isNotNull);
      },
    );
  });
}
