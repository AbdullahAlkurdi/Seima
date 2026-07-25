import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/startup/startup_screen.dart';
import 'package:seima/app/theme/app_theme.dart';

class SeimaApp extends StatelessWidget {
  const SeimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.instance<ThemeController>();
    return SeimaTheme(
      controller: controller,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: controller,
        builder: (context, mode, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            themeMode: mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: GetIt.instance<GoRouter>(),
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              return StartupScreen(child: child);
            },
          );
        },
      ),
    );
  }
}
