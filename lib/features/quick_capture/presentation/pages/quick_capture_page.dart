import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/data/id_provider.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';

class QuickCapturePage extends StatefulWidget {
  const QuickCapturePage({super.key});

  @override
  State<QuickCapturePage> createState() => _QuickCapturePageState();
}

class _QuickCapturePageState extends State<QuickCapturePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _repository = GetIt.instance<MindRepository>();
  List<Mind> _minds = [];
  Mind? _selectedMind;
  bool _saving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadMinds();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMinds() async {
    final minds = await _repository.loadAll();
    minds.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
    setState(() {
      _minds = minds;
      _selectedMind = minds.isNotEmpty ? minds.first : null;
    });
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    Mind mind;
    if (_selectedMind != null) {
      mind = _selectedMind!;
    } else {
      mind = Mind(id: generateId(), title: 'My Mind');
    }

    final node = MindNode(
      id: generateId(),
      mindId: mind.id,
      content: content,
      x: 100.0 + (mind.nodes.length % 5) * 220.0,
      y: 100.0 + (mind.nodes.length ~/ 5) * 150.0,
    );

    final updated = mind.copyWith(nodes: [...mind.nodes, node]);
    try {
      await _repository.save(updated);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _successMessage = 'Thought saved to "${updated.title}"';
        _controller.clear();
        _focusNode.requestFocus();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = 'Failed to save thought';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _cancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _cancel,
        ),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_minds.length > 1 || _minds.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<Mind>(
                  initialValue: _selectedMind,
                  decoration: const InputDecoration(
                    labelText: 'Add to Mind',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: _minds
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (m) => setState(() => _selectedMind = m),
                ),
              ),
            if (_selectedMind != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Adding to: ${_selectedMind!.title}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'What are you thinking about?',
                  border: InputBorder.none,
                  errorText: _errorMessage,
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
