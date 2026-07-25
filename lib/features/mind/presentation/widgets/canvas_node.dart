import 'package:flutter/material.dart';
import 'package:mindora/app/theme/spacing.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/domain/node_type.dart';

class CanvasNodeWidget extends StatelessWidget {
  final MindNode node;
  final bool isSelected;
  final bool isConnectionSource;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onDelete;
  final VoidCallback onStartConnection;
  final Function(double dx, double dy) onMove;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const CanvasNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isConnectionSource,
    required this.onTap,
    required this.onDoubleTap,
    required this.onDelete,
    required this.onStartConnection,
    required this.onMove,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayContent = node.content.isEmpty
        ? 'New $nodeTypeLabel'
        : node.content;
    final typeColor = node.type.color(colorScheme: cs);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor;
    if (isConnectionSource) {
      borderColor = cs.tertiary;
    } else if (isSelected) {
      borderColor = cs.primary;
    } else {
      borderColor = typeColor.withValues(alpha: isDark ? 0.5 : 0.3);
    }

    final nodeHeight = node.contentHeight;

    final semanticsLabel = node.content.isEmpty
        ? 'Empty $nodeTypeLabel'
        : '$nodeTypeLabel: ${node.content}';
    final semanticState = isSelected ? ', selected' : '';

    return Semantics(
      label: '$semanticsLabel$semanticState',
      container: true,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onPanStart: (_) => onDragStart?.call(),
        onPanEnd: (_) => onDragEnd?.call(),
        onPanCancel: () => onDragEnd?.call(),
        onPanUpdate: (details) {
          onMove(details.delta.dx, details.delta.dy);
        },
        child: Container(
          width: node.width,
          constraints: BoxConstraints(minHeight: nodeHeight),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(cs, Theme.of(context).textTheme.labelSmall),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s,
                  0,
                  AppSpacing.s,
                  AppSpacing.xs,
                ),
                child: Text(
                  displayContent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: node.content.isEmpty
                        ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                        : cs.onSurface,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (node.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s,
                    0,
                    AppSpacing.s,
                    AppSpacing.xs,
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: node.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: cs.onSecondaryContainer,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (isSelected) _buildActionBar(cs),
            ],
          ),
        ),
      ),
    );
  }

  String get nodeTypeLabel {
    switch (node.type) {
      case NodeType.text:
        return 'Text Node';
      case NodeType.task:
        return 'Task';
      case NodeType.question:
        return 'Question';
      case NodeType.idea:
        return 'Idea';
    }
  }

  Widget _buildHeader(ColorScheme cs, TextStyle? labelStyle) {
    final typeColor = node.type.color(colorScheme: cs);
    return Container(
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusMd - 1),
          topRight: Radius.circular(AppSpacing.radiusMd - 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 4,
      ),
      child: Row(
        children: [
          Icon(node.type.icon, size: 14, color: typeColor),
          const SizedBox(width: 4),
          Text(
            node.type.label,
            style: labelStyle?.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(ColorScheme cs) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusMd - 1),
          bottomRight: Radius.circular(AppSpacing.radiusMd - 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
            icon: Icons.link,
            tooltip: 'Connect',
            color: isConnectionSource ? cs.tertiary : null,
            onPressed: onStartConnection,
          ),
          _ActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onPressed: onDoubleTap,
          ),
          _ActionButton(
            icon: Icons.delete_outline,
            tooltip: 'Delete',
            color: cs.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 14),
        tooltip: tooltip,
        color: color ?? cs.onSurfaceVariant,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
