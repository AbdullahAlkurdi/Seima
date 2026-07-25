import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/app/widgets/mindora_loading_view.dart';
import 'package:seima/features/ai/domain/ai_failure.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/ai/presentation/cubit/ai_state.dart';
import 'package:seima/features/ai/presentation/widgets/proposal_card.dart';

class AIPanel extends StatelessWidget {
  final VoidCallback? onApplyNewNode;
  final void Function(NewNodeProposal)? onApplyNewNodeWithProposal;
  final void Function(ConnectionProposal)? onApplyConnection;
  final VoidCallback? onClose;

  const AIPanel({
    super.key,
    this.onApplyNewNode,
    this.onApplyNewNodeWithProposal,
    this.onApplyConnection,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(context),
              _buildModelStatusBar(context),
              Expanded(
                child: BlocBuilder<AICubit, AIState>(
                  builder: (context, state) {
                    if (state.isModelDownloading) {
                      return _buildDownloadProgress(context, state);
                    }
                    if (state.isLoading || state.isStreaming) {
                      return _buildLoading(context, state);
                    }
                    if (state.hasError) {
                      return _buildError(context, state.failure!);
                    }
                    if (state.status == AIStatus.initial) {
                      return _buildInitial(context, state);
                    }
                    return _buildContent(context, state);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.m),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          Text(
            'AI Analysis',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Close',
            onPressed: () {
              context.read<AICubit>().closePanel();
              onClose?.call();
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildModelStatusBar(BuildContext context) {
    return BlocBuilder<AICubit, AIState>(
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final isReady = state.isModelReady;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs,
          ),
          color: isReady
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surfaceContainerLow,
          child: Row(
            children: [
              Icon(
                isReady ? Icons.memory : Icons.info_outline,
                size: 14,
                color: isReady ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isReady ? 'Local AI model ready' : 'Using offline analysis',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isReady ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitial(BuildContext context, AIState state) {
    final cs = Theme.of(context).colorScheme;
    final isModelAvailable = state.isModelReady;
    final canDownload = state.modelState == ModelState.notAvailable;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isModelAvailable ? Icons.auto_awesome : Icons.tips_and_updates,
              size: 48,
              color: (isModelAvailable ? cs.primary : cs.onSurfaceVariant)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              isModelAvailable
                  ? 'Analyze with local AI'
                  : 'Analyze your mind map',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                isModelAvailable
                    ? 'Get LLM-powered insights, identify themes, and discover suggestions.'
                    : 'Get insights, identify themes, and discover suggestions to expand your thinking.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton.icon(
              onPressed: () => context.read<AICubit>().analyze(),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze This Mind'),
            ),
            if (canDownload) ...[
              const SizedBox(height: AppSpacing.m),
              TextButton.icon(
                onPressed: () => context.read<AICubit>().downloadModel(),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download local AI model (~1GB)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress(BuildContext context, AIState state) {
    final progress = state.downloadProgress ?? 0.0;
    final percent = (progress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SeimaLoadingView(
              variant: SeimaLoadingVariant.compact,
              progress: progress,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Downloading AI model...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Model runs entirely on your device.\nNo data is sent to the cloud.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, AIState state) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SeimaLoadingView(
            variant: SeimaLoadingVariant.compact,
            message: state.isStreaming
                ? 'Generating analysis...'
                : 'Analyzing your mind map...',
          ),
          if (state.isStreaming && state.hasAnalysis) ...[
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                state.analysisText!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, AIFailure failure) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton.icon(
              onPressed: () => context.read<AICubit>().retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AIState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasAnalysis) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: SelectableText(
                state.analysisText!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          if (state.hasProposals) ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              'Suggestions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s),
            ...state.proposals.map(
              (proposal) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: ProposalCard(
                  proposal: proposal,
                  onApplyNewNode: onApplyNewNodeWithProposal,
                  onApplyConnection: onApplyConnection,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Center(
            child: TextButton.icon(
              onPressed: () => context.read<AICubit>().clearAnalysis(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Run Again'),
            ),
          ),
        ],
      ),
    );
  }
}
