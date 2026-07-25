import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/home/presentation/cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<HomeCubit>()..load(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle theme',
            onPressed: () {
              final c = SeimaTheme.of(context);
              if (c.value == ThemeMode.dark) {
                c.system();
              } else {
                c.dark();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_outlined, size: 72, color: cs.primary),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    AppConfig.appName,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Phase ${state.phaseName}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'v${state.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton.icon(
                    onPressed: () {
                      final c = SeimaTheme.of(context);
                      switch (c.value) {
                        case ThemeMode.light:
                          c.dark();
                        case ThemeMode.dark:
                          c.system();
                        case ThemeMode.system:
                          c.light();
                      }
                    },
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Switch Theme'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
