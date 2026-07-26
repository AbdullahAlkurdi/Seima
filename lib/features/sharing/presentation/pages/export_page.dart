import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:seima/app/theme/spacing.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_state.dart';
import 'package:seima/features/sharing/data/export_service.dart';
import 'package:share_plus/share_plus.dart';

class ExportPage extends StatefulWidget {
  final String? mindId;

  const ExportPage({super.key, this.mindId});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _exportService = ExportService();
  bool _isExporting = false;

  Future<void> _exportMind(Mind mind) async {
    setState(() => _isExporting = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/Seima');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final path = await _exportService.exportToFile(mind, exportDir.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported to: $path'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _shareFile(path),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareFile(String path) async {
    if (!mounted) return;
    await Share.shareFiles(
      [path],
      text: 'Seima Export: ${Path.basename(path)}',
    );
  }

  Future<void> _copyToClipboard(Mind mind) async {
    try {
      await _exportService.copyToClipboard(mind);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copy failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _exportToText(Mind mind) {
    return _exportService.exportToText(mind);
  }

  void _showTextPreview(Mind mind) {
    final text = _exportToText(mind);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Text Preview'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(text)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<MindLibraryCubit, MindLibraryState>(
        builder: (context, state) {
          final minds = state.minds;

          if (minds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 64,
                    color: cs.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'No minds to export',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: minds.length,
            itemBuilder: (context, index) {
              final mind = minds[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mind.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          PopupMenuButton<String>(
onSelected: (value) async {
                                      switch (value) {
                                        case 'file':
                                          await _exportMind(mind);
                                        case 'clipboard':
                                          await _copyToClipboard(mind);
                                        case 'text':
                                          _showTextPreview(mind);
                                        case 'share':
                                          await _exportMind(mind);
                                          final dir =
                                              await getApplicationDocumentsDirectory();
                                          final exportDir =
                                              Directory('${dir.path}/Seima');
                                          if (await exportDir.exists()) {
                                            final files =
                                                exportDir.listSync();
                                            if (files.isNotEmpty) {
                                              _shareFile(
                                                  files.last.path);
                                            }
                                          }
                                      }
                                    },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'file',
                                child: ListTile(
                                  leading: Icon(Icons.save_alt),
                                  title: Text('Save as .seima'),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'clipboard',
                                child: ListTile(
                                  leading: Icon(Icons.copy),
                                  title: Text('Copy to Clipboard'),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'text',
                                child: ListTile(
                                  leading: Icon(Icons.text_fields),
                                  title: Text('Preview as Text'),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${mind.nodes.length} nodes · ${mind.connections.length} connections',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isExporting
          ? const CircularProgressIndicator()
          : null,
    );
  }
}
