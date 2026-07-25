import 'package:flutter/material.dart';
import 'package:mindora/app/theme/spacing.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/domain/node_type.dart';

class NodeEditorDialog extends StatefulWidget {
  final MindNode node;
  final ValueChanged<String> onSave;
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<NodeType>? onTypeChanged;

  const NodeEditorDialog({
    super.key,
    required this.node,
    required this.onSave,
    required this.onTagsChanged,
    this.onTypeChanged,
  });

  @override
  State<NodeEditorDialog> createState() => _NodeEditorDialogState();
}

class _NodeEditorDialogState extends State<NodeEditorDialog> {
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late List<String> _tags;
  late NodeType _selectedType;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.node.content);
    _tagController = TextEditingController();
    _tags = List.from(widget.node.tags);
    _selectedType = widget.node.type;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Node'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<NodeType>(
                segments: NodeType.values.map((type) {
                  return ButtonSegment(
                    value: type,
                    icon: Icon(type.icon, size: 16),
                    label: Text(
                      type.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (selected) {
                  setState(() => _selectedType = selected.first);
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _contentController,
                autofocus: true,
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Enter node content...',
                  labelText: 'Content',
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text('Tags', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add tag...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.s,
                        ),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _addTag,
                    tooltip: 'Add tag',
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => _removeTag(tag),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_contentController.text);
            widget.onTagsChanged(_tags);
            if (widget.onTypeChanged != null &&
                _selectedType != widget.node.type) {
              widget.onTypeChanged!(_selectedType);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
