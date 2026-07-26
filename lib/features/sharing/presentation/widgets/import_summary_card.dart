import 'package:flutter/material.dart';
import 'package:seima/app/theme/spacing.dart';

class ImportSummaryCard extends StatelessWidget {
  final dynamic preview;

  const ImportSummaryCard({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(_sourceIcon, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preview.title ?? 'Untitled',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (preview.sourceDescription != null)
                        Text(
                          preview.sourceDescription,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.l + AppSpacing.s),
            _buildInfoRow(context, 'Source', preview.sourceType ?? 'Unknown'),
            _buildInfoRow(context, 'Nodes', '${preview.nodeCount ?? 0}'),
            _buildInfoRow(
              context,
              'Connections',
              '${preview.connectionCount ?? 0}',
            ),
            if (preview.detectedTags?.isNotEmpty == true)
              _buildInfoRow(
                context,
                'Tags',
                (preview.detectedTags as List).take(5).join(', '),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _sourceIcon {
    final type = (preview.sourceType ?? '').toLowerCase();
    if (type.contains('seima')) return Icons.auto_awesome;
    if (type.contains('text')) return Icons.text_fields;
    if (type.contains('clipboard')) return Icons.content_paste;
    return Icons.import_contacts;
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
