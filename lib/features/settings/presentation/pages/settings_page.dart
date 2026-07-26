import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.light_mode_outlined,
                title: 'Theme',
                subtitle: 'Toggle light/dark mode',
                onTap: () {
                  final theme = SeimaTheme.of(context);
                  theme.toggle();
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'AI',
            children: [
              _SettingsTile(
                icon: Icons.auto_awesome,
                title: 'AI Model',
                subtitle: 'Manage local AI model',
                onTap: () => context.go('/ai-settings'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Data',
            children: [
              _SettingsTile(
                icon: Icons.import_export,
                title: 'Export / Import',
                subtitle: 'Backup and restore your minds',
                onTap: () => context.go('/export-import'),
              ),
              _SettingsTile(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear All Data',
                subtitle: 'Remove all minds and data',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear All Data'),
                      content: const Text(
                        'This will permanently delete all your minds '
                        'and data. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.error,
                            foregroundColor: cs.onError,
                          ),
                          onPressed: () async {
                          final cubit = GetIt.instance<MindLibraryCubit>();
                          await cubit.clearAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data cleared'),
                            ),
                          );
                        },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About Seima',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('About Seima'),
                      content: const SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seima v1.0.0',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            SizedBox(height: 12),
                            Text(
                                'A lightweight mind-mapping and knowledge '
                                'management application.'),
                            SizedBox(height: 8),
                            Text('Features:'),
                            SizedBox(height: 4),
                            Text('  • Create and organize minds'),
                            Text('  • Structured note nodes and connections'),
                            Text('  • Local AI analysis'),
                            Text('  • Import and export'),
                            Text('  • Search and quick capture'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.m,
            bottom: AppSpacing.xs,
            left: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
