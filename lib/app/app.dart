import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mindora/app/config/app_config.dart';
import 'package:mindora/app/theme/app_theme.dart';

class MindoraApp extends StatelessWidget {
  const MindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.instance<ThemeController>();
    return MindoraTheme(
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
          );
        },
      ),
    );
  }
}
