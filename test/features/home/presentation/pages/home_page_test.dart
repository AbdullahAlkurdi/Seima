import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/features/home/presentation/cubit/home_cubit.dart';
import 'package:seima/features/home/presentation/pages/home_page.dart';

void main() {
  setUp(() {
    final sl = GetIt.instance;
    if (!sl.isRegistered<ThemeController>()) {
      sl.registerLazySingleton<ThemeController>(() => ThemeController());
    }
    if (!sl.isRegistered<HomeCubit>()) {
      sl.registerFactory<HomeCubit>(() => HomeCubit());
    }
  });

  tearDown(() {
    final sl = GetIt.instance;
    sl.reset(dispose: false);
  });

  testWidgets('home page displays app name and phase', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.appName), findsAtLeastNWidgets(1));
    expect(find.text('Phase ${AppConfig.currentPhase}'), findsOneWidget);
    expect(find.text('v${AppConfig.appVersion}'), findsOneWidget);
  });

  testWidgets('home page has theme toggle button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomePage()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
  });
}
