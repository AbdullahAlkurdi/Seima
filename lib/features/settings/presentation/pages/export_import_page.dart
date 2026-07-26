import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';

class ExportImportPage extends StatelessWidget {
  const ExportImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export / Import'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _exportSection(cs, context),
          const SizedBox(height: AppSpacing.l),
          _importSection(cs, context),
        ],
      ),
    );
  }

  Widget _exportSection(ColorScheme cs, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Export your minds as .seima knowledge files.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.m),
            FilledButton.icon(
              onPressed: () => context.push('/export'),
              icon: const Icon(Icons.download),
              label: const Text('Export Minds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _importSection(ColorScheme cs, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Import .seima knowledge files or text content.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.m),
            FilledButton.icon(
              onPressed: () => context.push('/import'),
              icon: const Icon(Icons.upload),
              label: const Text('Import Content'),
            ),
          ],
        ),
      ),
    );
  }
}
