part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.phaseName = '',
    this.appVersion = '',
    this.isLoading = true,
  });

  final String phaseName;
  final String appVersion;
  final bool isLoading;

  HomeState copyWith({String? phaseName, String? appVersion, bool? isLoading}) {
    return HomeState(
      phaseName: phaseName ?? this.phaseName,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [phaseName, appVersion, isLoading];
}
