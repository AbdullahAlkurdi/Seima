import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seima/app/config/app_config.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void load() {
    emit(
      state.copyWith(
        phaseName: AppConfig.currentPhase,
        appVersion: AppConfig.appVersion,
        isLoading: false,
      ),
    );
  }
}
