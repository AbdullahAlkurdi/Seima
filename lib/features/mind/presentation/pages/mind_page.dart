import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/ai/data/mind_context_builder.dart';
import 'package:seima/features/ai/domain/ai_proposal.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/ai/presentation/cubit/ai_state.dart';
import 'package:seima/features/ai/presentation/widgets/ai_panel.dart';
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
        BlocProvider<AICubit>(create: (_) => GetIt.instance<AICubit>()),
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
  bool _isSelecting = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _onSelectionActive(bool active) {
    setState(() => _isSelecting = active);
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
    final aiCubit = context.read<AICubit>();
    final aiContext = const MindContextBuilder().build(mind);
    aiCubit.setContext(aiContext);
    aiCubit.openPanel();
  }

  void _applyNewNode(NewNodeProposal proposal) {
    final mindCubit = context.read<MindCubit>();
    final mind = mindCubit.state.mind;
    if (mind == null) return;
    mindCubit.beginBatchUndo();
    final x = 100.0 + (mind.nodes.length % 5) * 220;
    final y = 100.0 + (mind.nodes.length ~/ 5) * 150;
    mindCubit.createNode(x, y);
    final newNodeId = mindCubit.state.mind!.nodes.last.id;
    if (proposal.tags.isNotEmpty) {
      mindCubit.updateNodeTags(newNodeId, proposal.tags);
    }
    if (proposal.content.isNotEmpty) {
      mindCubit.updateNodeContent(newNodeId, proposal.content);
    }
    mindCubit.endBatchUndo();
  }

  void _applyConnection(ConnectionProposal proposal) {
    final mindCubit = context.read<MindCubit>();
    final mind = mindCubit.state.mind;
    if (mind == null) return;
    final nodeIds = mind.nodes.map((n) => n.id).toSet();
    if (!nodeIds.contains(proposal.sourceNodeId) ||
        !nodeIds.contains(proposal.targetNodeId)) {
      return;
    }
    final exists = mind.connections.any(
      (c) =>
          (c.sourceNodeId == proposal.sourceNodeId &&
              c.targetNodeId == proposal.targetNodeId) ||
          (c.sourceNodeId == proposal.targetNodeId &&
              c.targetNodeId == proposal.sourceNodeId),
    );
    if (exists) return;
    mindCubit.beginBatchUndo();
    mindCubit.startConnection(proposal.sourceNodeId);
    mindCubit.completeConnection(proposal.targetNodeId);
    mindCubit.endBatchUndo();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: CallbackShortcuts(
        bindings: buildMindShortcutBindings(
          onUndo: () => context.read<MindCubit>().undo(),
          onRedo: () => context.read<MindCubit>().redo(),
          onSelectAll: () => context.read<MindCubit>().selectAll(),
          onEscape: () {
            final aiCubit = context.read<AICubit>();
            if (aiCubit.state.isPanelOpen) {
              aiCubit.closePanel();
              return;
            }
            context.read<MindCubit>().onCanvasTap();
          },
          onDelete: () => context.read<MindCubit>().deleteSelectedNodes(),
        ),
        child: Scaffold(
          appBar: _MindAppBar(onAITap: _openAI),
          body: BlocBuilder<MindCubit, MindState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final mind = state.mind;
              if (mind == null) {
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: AppSpacing.l),
                        Text(
                          state.error!.message,
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fitToContent(mind);
              });

              return _buildCanvas(context, state, mind);
            },
          ),
          floatingActionButton: BlocBuilder<MindCubit, MindState>(
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
                  cubit.createNode(
                    100 + (state.mind?.nodes.length ?? 0) * 20,
                    100 + (state.mind?.nodes.length ?? 0) * 20,
                  );
                },
                child: const Icon(Icons.add),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, MindState state, dynamic mind) {
    final cubit = context.read<MindCubit>();
    final visibleRect = _computeVisibleRect();

    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            if (!HardwareKeyboard.instance.isShiftPressed) {
              cubit.onCanvasTap();
            }
          },
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            constrained: false,
            panEnabled: !_isSelecting,
            child: MindCanvas(
              mind: mind,
              selectedNodeIds: state.selectedNodeIds,
              selectedConnectionId: state.selectedConnectionId,
              connectionSourceNodeId: state.connectionSourceNodeId,
              visibleRect: visibleRect,
              onNodeTap: (id) {
                if (state.connectionSourceNodeId != null) {
                  cubit.completeConnection(id);
                } else if (HardwareKeyboard.instance.isControlPressed ||
                    HardwareKeyboard.instance.isMetaPressed) {
                  cubit.toggleNodeSelection(id);
                } else {
                  cubit.selectNode(id);
                }
              },
              onNodeDoubleTap: (id) => _editNode(context, id),
              onNodeDelete: (id) => cubit.deleteNode(id),
              onStartConnection: (id) => cubit.startConnection(id),
              onNodeMove: (id, dx, dy) {
                final selectedIds = state.selectedNodeIds;
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
              onSelectionChanged: _onSelectionChanged,
              onSelectionActive: _onSelectionActive,
            ),
          ),
        ),
        BlocBuilder<AICubit, AIState>(
          builder: (context, aiState) {
            if (!aiState.isPanelOpen) return const SizedBox();
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.85,
              child: AIPanel(
                onApplyNewNodeWithProposal: _applyNewNode,
                onApplyConnection: _applyConnection,
                onClose: () {},
              ),
            );
          },
        ),
      ],
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

  const _MindAppBar({required this.onAITap});

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
          ],
        );
      },
    );
  }
}
