import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/features/home/presentation/cubit/home_cubit.dart';

void main() {
  group('HomeCubit', () {
    test('initial state has isLoading true', () {
      final cubit = HomeCubit();
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.phaseName, '');
      expect(cubit.state.appVersion, '');
    });

    blocTest<HomeCubit, HomeState>(
      'load sets phase name and version',
      build: HomeCubit.new,
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeState(
          phaseName: AppConfig.currentPhase,
          appVersion: AppConfig.appVersion,
          isLoading: false,
        ),
      ],
    );
  });
}
