import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/app/widgets/seima_loading_view.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/ai/presentation/cubit/ai_state.dart';

class AIModelManagementPage extends StatelessWidget {
  const AIModelManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Model'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AICubit, AIState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              _modelStatusCard(cs, context, state),
              const SizedBox(height: AppSpacing.l),
              _modelActions(cs, context, state),
              const SizedBox(height: AppSpacing.l),
              _modelInfo(cs, state, context),
            ],
          );
        },
      ),
    );
  }

  Widget _modelStatusCard(ColorScheme cs, BuildContext context, AIState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Icon(
              state.isModelReady ? Icons.check_circle : Icons.warning_amber,
              size: 48,
              color: state.isModelReady ? cs.primary : cs.secondary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              state.isModelReady
                  ? 'Model Ready'
                  : state.isModelDownloading
                  ? 'Downloading...'
                  : 'Model Not Available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              state.isModelReady
                  ? 'Local AI is ready to analyze your minds.'
                  : state.isModelDownloading
                  ? 'Downloading the local AI model. '
                        'It runs entirely on your device.'
                  : 'No local AI model found. '
                        'Download one to get AI-powered insights.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modelActions(ColorScheme cs, BuildContext context, AIState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.m),
            if (state.isModelDownloading) ...[
              _buildDownloadProgress(cs, context, state),
              const SizedBox(height: AppSpacing.m),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AICubit>().cancelDownloadModel();
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Download'),
              ),
            ] else if (!state.isModelReady) ...[
              FilledButton.icon(
                onPressed: () => context.read<AICubit>().downloadModel(),
                icon: const Icon(Icons.download),
                label: const Text('Download Model (~1GB)'),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'The model runs entirely on your device. '
                'No data is sent to the cloud.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () => context.read<AICubit>().retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('Re-analyze'),
              ),
              const SizedBox(height: AppSpacing.s),
              OutlinedButton.icon(
                onPressed: () async {
                  final context = context;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removing model...'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  await context.read<AICubit>().modelManager?.deleteModel();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Model removed'),
                    ),
                  );
                  context.read<AICubit>().retry();
                },
                icon: Icon(Icons.delete_outline, color: cs.error),
                label: Text('Remove Model', style: TextStyle(color: cs.error)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress(
    ColorScheme cs,
    BuildContext context,
    AIState state,
  ) {
    final progress = state.downloadProgress ?? 0.0;
    final percent = (progress * 100).toInt();
    return Column(
      children: [
        SeimaLoadingView(
          variant: SeimaLoadingVariant.compact,
          progress: progress,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          '$percent%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _modelInfo(ColorScheme cs, AIState state, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Information',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s),
            _InfoRow(label: 'Type', value: 'Local LLM'),
            _InfoRow(
              label: 'Privacy',
              value: 'All processing stays on your device',
            ),
            _InfoRow(
              label: 'Status',
              value: state.isModelReady
                  ? 'Ready'
                  : state.isModelDownloading
                  ? 'Downloading'
                  : 'Not installed',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
