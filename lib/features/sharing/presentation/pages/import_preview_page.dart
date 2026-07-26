import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:seima/features/sharing/presentation/cubit/import_cubit.dart';
import 'package:seima/features/sharing/presentation/cubit/import_state.dart';
import 'package:seima/features/sharing/presentation/widgets/import_destination_picker.dart';
import 'package:seima/features/sharing/presentation/widgets/import_summary_card.dart';

class ImportPreviewPage extends StatelessWidget {
  final String? initialContent;

  const ImportPreviewPage({super.key, this.initialContent});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportCubit>(
      create: (_) {
        final cubit = GetIt.instance<ImportCubit>();
        if (initialContent != null) {
          cubit.setPendingContent(initialContent!);
          cubit.previewPendingContent();
        }
        return cubit;
      },
      child: const _ImportPreviewBody(),
    );
  }
}

class _ImportPreviewBody extends StatelessWidget {
  const _ImportPreviewBody();

  void _handleCancel(BuildContext context) {
    context.read<ImportCubit>().reset();
    context.pop();
  }

  Future<void> _handleImportAsNew(BuildContext context) async {
    final cubit = context.read<ImportCubit>();
    final mind = await cubit.executeAsNewMind();
    if (mind != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported "${mind.title}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
      context.push('/mind/${mind.id}');
    }
  }

  Future<void> _handleMergeIntoMind(BuildContext context) async {
    final minds = context.read<MindLibraryCubit>().state.minds;

    if (!context.mounted) return;
    final targetMind = await showDialog<Mind>(
      context: context,
      builder: (ctx) => ImportDestinationPicker(minds: minds),
    );

    if (targetMind == null || !context.mounted) return;

    final cubit = context.read<ImportCubit>();
    final result = await cubit.executeMergeIntoMind(targetMind);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merged into "${targetMind.title}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
      context.push('/mind/${result.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleCancel(context),
        ),
      ),
      body: BlocConsumer<ImportCubit, ImportState>(
        listener: (context, state) {
          if (state.step == ImportStep.failure && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.step) {
            case ImportStep.initial:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.import_contacts,
                      size: 64,
                      color: cs.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Select content to import',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );

            case ImportStep.loading:
              return const Center(child: CircularProgressIndicator());

            case ImportStep.preview:
              final preview = state.preview!;
              return _buildPreview(context, preview, state);

            case ImportStep.executing:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Importing...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );

            case ImportStep.success:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: cs.primary),
                    const SizedBox(height: AppSpacing.m),
                    const Text('Import complete!'),
                  ],
                ),
              );

            case ImportStep.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: cs.error),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        state.failure?.message ?? 'Import failed',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      FilledButton(
                        onPressed: () {
                          context.read<ImportCubit>().reset();
                          context.pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    dynamic preview,
    ImportState state,
  ) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImportSummaryCard(preview: preview),
          const SizedBox(height: AppSpacing.m),
          if (preview.hasErrors)
            Card(
              color: cs.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issues Found',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    ...preview.errors.map<Widget>(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error, size: 16, color: cs.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e,
                                style: TextStyle(color: cs.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (preview.hasWarnings)
            Card(
              color: cs.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warnings',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    ...preview.warnings.map<Widget>(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: cs.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(w)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          if (!preview.hasErrors)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleCancel(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                if (state.step != ImportStep.executing) ...[
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _handleImportAsNew(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Mind'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _handleMergeIntoMind(context),
                      icon: const Icon(Icons.merge),
                      label: const Text('Merge'),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
