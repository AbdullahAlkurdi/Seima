import 'package:flutter/material.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/domain/mind.dart';

class ImportDestinationPicker extends StatelessWidget {
  final List<Mind> minds;

  const ImportDestinationPicker({super.key, required this.minds});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Import to Existing Mind'),
      content: SizedBox(
        width: double.maxFinite,
        child: minds.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Text(
                  'No existing minds. Create a new one instead.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: minds.length,
                itemBuilder: (context, index) {
                  final mind = minds[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.lightbulb,
                        color: cs.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(mind.title),
                    subtitle: Text(
                      '${mind.nodes.length} nodes',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    onTap: () => Navigator.of(context).pop(mind),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
