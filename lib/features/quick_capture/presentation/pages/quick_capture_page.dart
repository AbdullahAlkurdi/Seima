import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
    setState(() => _saving = true);

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
    await _repository.save(updated);

    if (mounted) {
      context.go('/mind/${updated.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_minds.length > 1)
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
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'What are you thinking about?',
                  border: InputBorder.none,
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
