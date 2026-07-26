import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/app/widgets/seima_loading_view.dart';
import 'package:seima/features/ai/data/mind_context_builder.dart';
import 'package:seima/features/ai/domain/ai_failure.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/ai/presentation/cubit/ai_state.dart';
import 'package:seima/features/ai/presentation/widgets/proposal_card.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/mind_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/mind_state.dart';

class AIAnalysisPage extends StatelessWidget {
  final String mindId;

  const AIAnalysisPage({super.key, required this.mindId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AICubit>(create: (_) => GetIt.instance<AICubit>()),
        BlocProvider<MindCubit>(
          create: (_) {
            final cubit = GetIt.instance<MindCubit>();
            cubit.loadMind(mindId);
            return cubit;
          },
        ),
      ],
      child: _AIAnalysisBody(mindId: mindId),
    );
  }
}

class _AIAnalysisBody extends StatelessWidget {
  final String mindId;

  const _AIAnalysisBody({required this.mindId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Analyze',
            onPressed: () {
              final mindCubit = context.read<MindCubit>();
              final mind = mindCubit.state.mind;
              if (mind == null) return;
              final aiCubit = context.read<AICubit>();
              final aiContext = const MindContextBuilder().build(mind);
              aiCubit.setContext(aiContext);
              aiCubit.analyze();
            },
          ),
        ],
      ),
      body: BlocBuilder<MindCubit, MindState>(
        builder: (context, mindState) {
          if (mindState.isLoading) {
            return const SeimaLoadingView(
              variant: SeimaLoadingVariant.fullPage,
              message: 'Loading mind...',
            );
          }
          if (mindState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: AppSpacing.l),
                  Text(mindState.error!.message),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: () => context.read<MindCubit>().loadMind(mindId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final mind = mindState.mind;
          if (mind == null) {
            return Center(
              child: Text(
                'Mind not found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          return _buildResults(context, mind);
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, Mind mind) {
    return BlocBuilder<AICubit, AIState>(
      builder: (context, aiState) {
        if (aiState.isModelDownloading) {
          return _buildDownloadProgress(context, aiState);
        }
        if (aiState.isLoading || aiState.isStreaming) {
          return _buildLoading(context, aiState);
        }
        if (aiState.hasError) {
          return _buildError(context, aiState.failure!);
        }
        if (aiState.status == AIStatus.initial) {
          return _buildInitial(context, aiState, mind);
        }
        return _buildContent(context, aiState, mind);
      },
    );
  }

  Widget _buildInitial(BuildContext context, AIState state, Mind mind) {
    final cs = Theme.of(context).colorScheme;
    final isModelAvailable = state.isModelReady;
    final canDownload = state.modelState == ModelState.notAvailable;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isModelAvailable ? Icons.auto_awesome : Icons.tips_and_updates,
            size: 64,
            color: (isModelAvailable ? cs.primary : cs.onSurfaceVariant)
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            isModelAvailable
                ? 'Analyze with local AI'
                : 'Analyze this mind map',
            style: Theme.of(context).textTheme.headlineSmall,
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
          Text(
            'Mind: ${mind.title}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${mind.nodes.length} nodes \u00b7 ${mind.connections.length} connections',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () {
              final aiCubit = context.read<AICubit>();
              final aiContext = const MindContextBuilder().build(mind);
              aiCubit.setContext(aiContext);
              aiCubit.analyze();
            },
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
    );
  }

  Widget _buildDownloadProgress(BuildContext context, AIState state) {
    final progress = state.downloadProgress ?? 0.0;
    final percent = (progress * 100).toInt();
    final cs = Theme.of(context).colorScheme;

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
            const SizedBox(height: AppSpacing.l),
            Text(
              'Downloading AI model...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$percent%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Model runs entirely on your device.\nNo data is sent to the cloud.',
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

  Widget _buildContent(BuildContext context, AIState state, Mind mind) {
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
                  onApplyNewNode: (p) {
                    final mindCubit = context.read<MindCubit>();
                    final mind = mindCubit.state.mind;
                    if (mind == null) return;
                    mindCubit.beginBatchUndo();
                    final x = 100.0 + (mind.nodes.length % 5) * 220;
                    final y = 100.0 + (mind.nodes.length ~/ 5) * 150;
                    mindCubit.createNode(x, y);
                    final newNodeId = mindCubit.state.mind!.nodes.last.id;
                    if (p.tags.isNotEmpty) {
                      mindCubit.updateNodeTags(newNodeId, p.tags);
                    }
                    if (p.content.isNotEmpty) {
                      mindCubit.updateNodeContent(newNodeId, p.content);
                    }
                    mindCubit.endBatchUndo();
                  },
                  onApplyConnection: (p) {
                    final mindCubit = context.read<MindCubit>();
                    final mind = mindCubit.state.mind;
                    if (mind == null) return;
                    final nodeIds = mind.nodes.map((n) => n.id).toSet();
                    if (!nodeIds.contains(p.sourceNodeId) ||
                        !nodeIds.contains(p.targetNodeId)) {
                      return;
                    }
                    final exists = mind.connections.any(
                      (c) =>
                          (c.sourceNodeId == p.sourceNodeId &&
                              c.targetNodeId == p.targetNodeId) ||
                          (c.sourceNodeId == p.targetNodeId &&
                              c.targetNodeId == p.sourceNodeId),
                    );
                    if (exists) return;
                    mindCubit.beginBatchUndo();
                    mindCubit.startConnection(p.sourceNodeId);
                    mindCubit.completeConnection(p.targetNodeId);
                    mindCubit.endBatchUndo();
                  },
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
