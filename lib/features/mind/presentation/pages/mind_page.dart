import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/core/errors/failures.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/mind_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/mind_state.dart';
import 'package:seima/features/mind/presentation/widgets/mind_canvas.dart';
import 'package:seima/features/mind/presentation/widgets/node_editor.dart';
import 'package:seima/features/mind/presentation/widgets/shortcut_registry.dart';

class MindPage extends StatelessWidget {
  final String? mindId;

  const MindPage({super.key, this.mindId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MindCubit>(
          create: (_) {
            final cubit = GetIt.instance<MindCubit>();
            if (mindId != null) {
              cubit.loadMind(mindId!);
            } else {
              cubit.loadMostRecent();
            }
            return cubit;
          },
        ),
      ],
      child: const _MindBody(),
    );
  }
}

class _MindBody extends StatefulWidget {
  const _MindBody();

  @override
  State<_MindBody> createState() => _MindBodyState();
}

class _MindBodyState extends State<_MindBody> {
  final FocusNode _focusNode = FocusNode();
  final TransformationController _transformController =
      TransformationController();
  bool _hasFittedContent = false;
  StreamSubscription<MindState>? _mindSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mindSub = context.read<MindCubit>().stream.listen((state) {
        if (_hasFittedContent || state.mind == null || state.mind!.nodes.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_hasFittedContent && mounted) {
            _fitToContent(state.mind!);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _transformController.dispose();
    _mindSub?.cancel();
    super.dispose();
  }

  void _onSelectionChanged(Set<String> ids) {
    final cubit = context.read<MindCubit>();
    cubit.clearSelection();
    for (final id in ids) {
      cubit.toggleNodeSelection(id);
    }
  }

  void _fitToContent(Mind mind) {
    if (_hasFittedContent || mind.nodes.isEmpty) return;
    _hasFittedContent = true;

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final node in mind.nodes) {
      if (node.x < minX) minX = node.x;
      if (node.y < minY) minY = node.y;
      if (node.x + node.width > maxX) maxX = node.x + node.width;
      if (node.y + node.height > maxY) maxY = node.y + node.height;
    }

    final bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    final size = MediaQuery.of(context).size;
    const padding = 80.0;
    final scaleX = (size.width - padding * 2) / bounds.width;
    final scaleY = (size.height - padding * 2) / bounds.height;
    final scale = math.min(scaleX, scaleY).clamp(0.5, 1.5);

    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy;
    final tx = size.width / 2 - centerX * scale;
    final ty = size.height / 2 - centerY * scale;
    _transformController.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(tx, ty, 0);
  }

  Rect _computeVisibleRect() {
    final matrix = _transformController.value;
    final inv = Matrix4.inverted(matrix);
    final size = MediaQuery.of(context).size;
    final topLeft = MatrixUtils.transformPoint(inv, Offset.zero);
    final bottomRight = MatrixUtils.transformPoint(
      inv,
      Offset(size.width, size.height),
    );
    return Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
  }

  void _openAI() {
    final mind = context.read<MindCubit>().state.mind;
    if (mind == null) return;
    context.go('/ai-analysis/${mind.id}');
  }

  void _showDeleteDialog(BuildContext context) {
    final cubit = context.read<MindCubit>();
    final mind = cubit.state.mind;
    if (mind == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mind'),
        content: Text('Delete "${mind.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              cubit.deleteMind(mind.id);
              context.go('/');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRect = _computeVisibleRect();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: buildMindShortcutBindings(
          onUndo: () => context.read<MindCubit>().undo(),
          onRedo: () => context.read<MindCubit>().redo(),
          onSelectAll: () => context.read<MindCubit>().selectAll(),
          onEscape: () {
            context.read<MindCubit>().onCanvasTap();
          },
          onDelete: () => context.read<MindCubit>().deleteSelectedNodes(),
        ),
        child: Scaffold(
          appBar: _MindAppBar(
            onAITap: _openAI,
            onRename: () => _showRenameDialog(context),
            onDelete: () => _showDeleteDialog(context),
          ),
          body: Stack(
            children: [
              _CanvasArea(
                transformController: _transformController,
                visibleRect: visibleRect,
                onEditNode: _editNode,
                onSelectionChanged: _onSelectionChanged,
              ),
              const _ConnectionBannerArea(),
            ],
          ),
          floatingActionButton: _buildFab(),
        ),
      ),
    );
  }

  Widget _buildFab() {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<MindCubit, MindState>(
      builder: (context, state) {
        if (state.connectionSourceNodeId != null) {
          return FloatingActionButton.extended(
            heroTag: 'cancel_connection',
            onPressed: () => context.read<MindCubit>().cancelConnection(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel Connection'),
            backgroundColor: cs.errorContainer,
            foregroundColor: cs.onErrorContainer,
          );
        }
        return FloatingActionButton(
          heroTag: 'add_node',
          onPressed: () {
            final cubit = context.read<MindCubit>();
            final count = state.mind?.nodes.length ?? 0;
            cubit.createNode(
              100.0 + (count % 5) * 220,
              100.0 + (count ~/ 5) * 150,
            );
          },
          child: const Icon(Icons.add),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    final cubit = context.read<MindCubit>();
    final mind = cubit.state.mind;
    if (mind == null) return;
    final controller = TextEditingController(text: mind.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Mind'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Enter a new title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                cubit.updateTitle(newTitle);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _editNode(BuildContext context, String nodeId) {
    final cubit = context.read<MindCubit>();
    final mind = cubit.state.mind;
    if (mind == null) return;
    final node = mind.nodes.firstWhere((n) => n.id == nodeId);
    showDialog(
      context: context,
      builder: (ctx) => NodeEditorDialog(
        node: node,
        onSave: (content) => cubit.updateNodeContent(nodeId, content),
        onTagsChanged: (tags) => cubit.updateNodeTags(nodeId, tags),
        onTypeChanged: (type) => cubit.changeNodeType(nodeId, type),
      ),
    );
  }
}

class _MindAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAITap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const _MindAppBar({
    required this.onAITap,
    this.onRename,
    this.onDelete,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<MindCubit, MindState>(
      builder: (context, state) {
        final title = state.mind?.title ?? AppConfig.appName;
        final isSaving = state.isSaving;
        final selectionCount = state.selectedNodeIds.length;
        return AppBar(
          title: Text(title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Library',
            onPressed: () => context.go('/'),
          ),
          actions: [
IconButton(
               icon: const Icon(Icons.share),
               tooltip: 'Share Mind',
               onPressed: () {
                 final mind = context.read<MindCubit>().state.mind;
                 if (mind != null) {
                   context.push('/export/${mind.id}');
                 }
               },
             ),
             IconButton(
               icon: const Icon(Icons.edit_note),
               tooltip: 'Quick Capture',
               onPressed: () => context.push('/quick-capture'),
             ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'AI Analysis',
              onPressed: onAITap,
            ),
            if (state.canUndo)
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () => context.read<MindCubit>().undo(),
              ),
            if (state.canRedo)
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
                onPressed: () => context.read<MindCubit>().redo(),
              ),
            if (state.connectionSourceNodeId != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Connect mode',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            if (selectionCount > 1)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '$selectionCount selected',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            if (isSaving)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
IconButton(
               icon: const Icon(Icons.light_mode_outlined),
               tooltip: 'Toggle theme',
               onPressed: () {
                 SeimaTheme.of(context).toggle();
               },
             ),
             PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename?.call();
                    case 'delete':
                      onDelete?.call();
                    case 'settings':
                      context.push('/workspace-settings');
                  }
                },
               itemBuilder: (context) => [
                 const PopupMenuItem(
                   value: 'rename',
                   child: ListTile(
                     leading: Icon(Icons.edit_outlined),
                     title: Text('Rename'),
                     dense: true,
                     contentPadding: EdgeInsets.zero,
                   ),
                 ),
                 const PopupMenuItem(
                   value: 'delete',
                   child: ListTile(
                     leading: Icon(Icons.delete_outline, color: Colors.red),
                     title: Text('Delete Mind',
                         style: TextStyle(color: Colors.red)),
                     dense: true,
                     contentPadding: EdgeInsets.zero,
                     ),
                   ),
                 ],
                ),
              ],
            );
          },
        );
    }
  }

class _CanvasPayload {
  final bool isLoading;
  final Failure? error;
  final Mind? mind;
  final Set<String> selectedNodeIds;
  final String? selectedConnectionId;
  final String? connectionSourceNodeId;

  const _CanvasPayload({
    required this.isLoading,
    this.error,
    this.mind,
    required this.selectedNodeIds,
    this.selectedConnectionId,
    this.connectionSourceNodeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CanvasPayload &&
          isLoading == other.isLoading &&
          error == other.error &&
          mind == other.mind &&
          setEquals(selectedNodeIds, other.selectedNodeIds) &&
          selectedConnectionId == other.selectedConnectionId &&
          connectionSourceNodeId == other.connectionSourceNodeId;

  @override
  int get hashCode => Object.hash(
    isLoading,
    error,
    mind,
    Object.hashAllUnordered(selectedNodeIds),
    selectedConnectionId,
    connectionSourceNodeId,
  );
}

class _BannerPayload {
  final String? connectionSourceNodeId;
  final String? sourceLabel;

  const _BannerPayload(this.connectionSourceNodeId, this.sourceLabel);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BannerPayload &&
          connectionSourceNodeId == other.connectionSourceNodeId &&
          sourceLabel == other.sourceLabel;

  @override
  int get hashCode => Object.hash(connectionSourceNodeId, sourceLabel);
}

class _CanvasArea extends StatelessWidget {
  final TransformationController transformController;
  final Rect visibleRect;
  final void Function(BuildContext, String) onEditNode;
  final void Function(Set<String>) onSelectionChanged;

  const _CanvasArea({
    required this.transformController,
    required this.visibleRect,
    required this.onEditNode,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MindCubit, MindState, _CanvasPayload>(
      selector: (state) => _CanvasPayload(
        isLoading: state.isLoading,
        error: state.error,
        mind: state.mind,
        selectedNodeIds: state.selectedNodeIds,
        selectedConnectionId: state.selectedConnectionId,
        connectionSourceNodeId: state.connectionSourceNodeId,
      ),
      builder: (context, payload) {
        final cs = Theme.of(context).colorScheme;
        if (payload.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final mind = payload.mind;
        if (mind == null) {
          if (payload.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    payload.error!.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: () =>
                        context.read<MindCubit>().loadMostRecent(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        }
        if (mind.nodes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 64,
                  color: cs.primary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'No nodes yet',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Tap + to create your first node',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }
        final cubit = context.read<MindCubit>();
        return GestureDetector(
          onTapDown: (details) {
            if (payload.connectionSourceNodeId != null) return;
            if (!HardwareKeyboard.instance.isShiftPressed) {
              cubit.onCanvasTap();
            }
          },
          child: InteractiveViewer(
            transformationController: transformController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            constrained: false,
            panEnabled: true,
            child: MindCanvas(
              mind: mind,
              selectedNodeIds: payload.selectedNodeIds,
              selectedConnectionId: payload.selectedConnectionId,
              connectionSourceNodeId: payload.connectionSourceNodeId,
              visibleRect: visibleRect,
              onNodeTap: (id) {
                if (payload.connectionSourceNodeId != null) {
                  cubit.completeConnection(id);
                } else if (HardwareKeyboard.instance.isControlPressed ||
                    HardwareKeyboard.instance.isMetaPressed) {
                  cubit.toggleNodeSelection(id);
                } else {
                  cubit.selectNode(id);
                }
              },
              onNodeDoubleTap: (id) => onEditNode(context, id),
              onNodeDelete: (id) => cubit.deleteNode(id),
              onStartConnection: (id) => cubit.startConnection(id),
              onNodeMove: (id, dx, dy) {
                final selectedIds = payload.selectedNodeIds;
                if (selectedIds.length > 1 && selectedIds.contains(id)) {
                  cubit.moveSelectedNodes(dx, dy);
                } else {
                  final node = mind.nodes.firstWhere((n) => n.id == id);
                  cubit.moveNode(id, node.x + dx, node.y + dy);
                }
              },
              onNodeDragStart: () => cubit.beginNodeDrag(),
              onNodeDragEnd: () => cubit.endNodeDrag(),
              onConnectionTap: (id) => cubit.onConnectionTap(id),
              onCanvasTap: () => cubit.onCanvasTap(),
              onSelectionChanged: onSelectionChanged,
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionBannerArea extends StatelessWidget {
  const _ConnectionBannerArea();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocSelector<MindCubit, MindState, _BannerPayload>(
      selector: (state) {
        String? label;
        if (state.connectionSourceNodeId != null && state.mind != null) {
          try {
            final source = state.mind!.nodes.firstWhere(
              (n) => n.id == state.connectionSourceNodeId,
            );
            if (source.content.isNotEmpty) {
              label = source.content.split('\n').first.trim();
            }
          } catch (_) {}
        }
        return _BannerPayload(state.connectionSourceNodeId, label);
      },
      builder: (context, payload) {
        if (payload.connectionSourceNodeId == null) return const SizedBox();
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: cs.tertiaryContainer.withValues(alpha: 0.95),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                Icon(Icons.link, size: 16, color: cs.onTertiaryContainer),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    payload.sourceLabel != null
                        ? 'Connecting from "${payload.sourceLabel}"'
                        : 'Connection mode',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onTertiaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      context.read<MindCubit>().cancelConnection(),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
        );
      },
    );
  }
}

