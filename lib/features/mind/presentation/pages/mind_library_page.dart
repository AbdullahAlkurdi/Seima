import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/config/app_config.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_state.dart';

class MindLibraryPage extends StatefulWidget {
  const MindLibraryPage({super.key});

  @override
  State<MindLibraryPage> createState() => _MindLibraryPageState();
}

class _MindLibraryPageState extends State<MindLibraryPage> {
  late MindLibraryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<MindLibraryCubit>();
    _cubit.loadAll();
  }

  void _openMind(String id) {
    context.push('/mind/$id');
  }

  Future<void> _createMind() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final result = await showDialog<(String name, String? category)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Mind'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Mind Name',
                hintText: 'e.g., Project Alpha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: categoryController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                hintText: 'e.g., Work, Learning, Personal',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final cat = categoryController.text.trim();
              Navigator.of(ctx).pop((name, cat.isEmpty ? null : cat));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    final mind = await _cubit.create(title: result.$1, category: result.$2);
    if (mind != null && mounted) {
      _openMind(mind.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created "${mind.title}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _renameMind(String id, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Mind'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter mind name...',
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _cubit.rename(id, controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteMind(String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mind'),
        content: Text('Delete "$title"? This cannot be undone.'),
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
              _cubit.delete(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MindLibraryCubit>.value(
      value: _cubit,
      child: _MindLibraryBody(
        onOpenMind: _openMind,
        onCreateMind: _createMind,
        onRenameMind: _renameMind,
        onDeleteMind: _deleteMind,
      ),
    );
  }
}

class _MindLibraryBody extends StatelessWidget {
  final void Function(String id) onOpenMind;
  final VoidCallback onCreateMind;
  final void Function(String id, String currentTitle) onRenameMind;
  final void Function(String id, String title) onDeleteMind;

  const _MindLibraryBody({
    required this.onOpenMind,
    required this.onCreateMind,
    required this.onRenameMind,
    required this.onDeleteMind,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Import',
            onPressed: () => context.push('/import'),
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Export',
            onPressed: () => context.push('/export'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Quick Capture',
            onPressed: () => context.push('/quick-capture'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle theme',
            onPressed: () {
              final c = SeimaTheme.of(context);
              c.toggle();
            },
          ),
        ],
      ),
      body: BlocBuilder<MindLibraryCubit, MindLibraryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: AppSpacing.l),
                  Text(state.error!.message),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: () => context.read<MindLibraryCubit>().loadAll(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.minds.isEmpty) {
            return _buildEmptyState(context, cs);
          }
          return _buildMindList(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreateMind,
        icon: const Icon(Icons.add),
        label: const Text('New Mind'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: cs.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Welcome to Seima',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Create your first mind to get started.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreateMind,
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Mind'),
          ),
        ],
      ),
    );
  }

  Widget _buildMindList(BuildContext context, MindLibraryState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<MindLibraryCubit>().loadAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: state.minds.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
        itemBuilder: (context, index) {
          final mind = state.minds[index];
          return _MindCard(
            mind: mind,
            onTap: () => onOpenMind(mind.id),
            onRename: () => onRenameMind(mind.id, mind.title),
            onDuplicate: () =>
                context.read<MindLibraryCubit>().duplicate(mind.id),
            onDelete: () => onDeleteMind(mind.id, mind.title),
          );
        },
      ),
    );
  }
}

class _MindCard extends StatelessWidget {
  final dynamic mind;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _MindCard({
    required this.mind,
    required this.onTap,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nodeCount = mind.nodes.length;
    final connCount = mind.connections.length;
    final daysSince = DateTime.now().difference(mind.lastAccessedAt).inDays;
    final lastAccessed = daysSince == 0
        ? 'Today'
        : daysSince == 1
        ? 'Yesterday'
        : '$daysSince days ago';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(Icons.lightbulb, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mind.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (mind.category != null && mind.category!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mind.category!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      '$nodeCount nodes · $connCount connections · $lastAccessed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename();
                    case 'duplicate':
                      onDuplicate();
                    case 'delete':
                      onDelete();
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
                    value: 'duplicate',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Duplicate'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outlined, color: Colors.red),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
