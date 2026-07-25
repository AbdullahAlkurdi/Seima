import 'package:flutter/material.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';

class ProposalCard extends StatelessWidget {
  final AIProposal proposal;
  final void Function(NewNodeProposal)? onApplyNewNode;
  final void Function(ConnectionProposal)? onApplyConnection;

  const ProposalCard({
    super.key,
    required this.proposal,
    this.onApplyNewNode,
    this.onApplyConnection,
  });

  @override
  Widget build(BuildContext context) {
    return switch (proposal) {
      NewNodeProposal p => _buildNewNodeCard(context, p),
      ConnectionProposal p => _buildConnectionCard(context, p),
    };
  }

  Widget _buildNewNodeCard(BuildContext context, NewNodeProposal p) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, size: 18, color: cs.primary),
                const SizedBox(width: AppSpacing.s),
                Text(
                  'Suggested Node',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(p.content, style: Theme.of(context).textTheme.bodyMedium),
            if (p.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: 4,
                children: p.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                color: cs.onSecondaryContainer,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (p.reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                p.reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => onApplyNewNode?.call(p),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add to Mind'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context, ConnectionProposal p) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, size: 18, color: cs.tertiary),
                const SizedBox(width: AppSpacing.s),
                Text(
                  'Suggested Connection',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '${p.sourceNodeId} â†’ ${p.targetNodeId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            if (p.reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                p.reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => onApplyConnection?.call(p),
                icon: const Icon(Icons.link, size: 16),
                label: const Text('Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
