import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/sharing/domain/seima_knowledge_package.dart';

class ExportResult {
  final String path;
  final SeimaKnowledgePackage package;

  const ExportResult({required this.path, required this.package});
}

class ExportService {
  SeimaKnowledgePackage exportMind(Mind mind) {
    final nodeIds = <String>{};
    final packageNodeMap = <String, PackageNode>{};

    for (final node in mind.nodes) {
      final pkgNode = PackageNode(
        id: node.id,
        type: node.type.name,
        content: node.content,
        tags: List<String>.from(node.tags),
        x: node.x,
        y: node.y,
        width: node.width,
        height: node.height,
        createdAt: node.createdAt,
        updatedAt: node.updatedAt,
      );
      nodeIds.add(node.id);
      packageNodeMap[node.id] = pkgNode;
    }

    final pkgConnections = mind.connections.map((conn) {
      return PackageConnection(
        id: conn.id,
        sourceId: conn.sourceNodeId,
        targetId: conn.targetNodeId,
        createdAt: conn.createdAt,
      );
    }).toList();

    final pkgMind = PackageMind(
      id: mind.id,
      title: mind.title,
      description: mind.description,
      category: mind.category,
      createdAt: mind.createdAt,
      updatedAt: mind.updatedAt,
    );

    return SeimaKnowledgePackage(
      mind: pkgMind,
      nodes: packageNodeMap.values.toList(),
      connections: pkgConnections,
      provenance: PackageProvenance(
        exportedBy: 'seima_export',
        sourceApp: 'seima',
        notes: 'Exported from Seima mind workspace',
      ),
    );
  }

  SeimaKnowledgePackage exportNodes({
    required Mind mind,
    required List<MindNode> selectedNodes,
  }) {
    final selectedIds = selectedNodes.map((n) => n.id).toSet();
    final pkgNodes = selectedNodes.map((node) {
      return PackageNode(
        id: node.id,
        type: node.type.name,
        content: node.content,
        tags: List<String>.from(node.tags),
        x: node.x,
        y: node.y,
        width: node.width,
        height: node.height,
        createdAt: node.createdAt,
        updatedAt: node.updatedAt,
      );
    }).toList();

    final pkgConnections = mind.connections
        .where(
          (c) =>
              selectedIds.contains(c.sourceNodeId) &&
              selectedIds.contains(c.targetNodeId),
        )
        .map(
          (conn) => PackageConnection(
            id: conn.id,
            sourceId: conn.sourceNodeId,
            targetId: conn.targetNodeId,
            createdAt: conn.createdAt,
          ),
        )
        .toList();

    return SeimaKnowledgePackage(
      mind: PackageMind(
        id: mind.id,
        title: '${mind.title} (selected)',
        description: mind.description,
      ),
      nodes: pkgNodes,
      connections: pkgConnections,
      provenance: PackageProvenance(
        exportedBy: 'seima_export',
        sourceApp: 'seima',
      ),
    );
  }

  Future<String> exportToFile(Mind mind, String directory) async {
    final package = exportMind(mind);
    final sanitized = mind.title.replaceAll(RegExp(r'[^\w\s-]'), '');
    final filename =
        '${sanitized}_${DateTime.now().millisecondsSinceEpoch}.seima';
    final path = '$directory${Platform.pathSeparator}$filename';
    final file = File(path);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(package.toJson()),
      flush: true,
    );
    return path;
  }

  Future<String> exportPackageToFile(
    SeimaKnowledgePackage package,
    String directory, {
    String? filename,
  }) async {
    final name =
        filename ??
        'seima_export_${DateTime.now().millisecondsSinceEpoch}.seima';
    final path = '$directory${Platform.pathSeparator}$name';
    final file = File(path);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(package.toJson()),
      flush: true,
    );
    return path;
  }

  String exportToText(Mind mind) {
    final buffer = StringBuffer();
    buffer.writeln(mind.title);
    if (mind.description != null && mind.description!.isNotEmpty) {
      buffer.writeln(mind.description);
    }
    buffer.writeln('─' * 40);

    final nodeMap = {for (final n in mind.nodes) n.id: n};

    for (final conn in mind.connections) {
      final source = nodeMap[conn.sourceNodeId];
      final target = nodeMap[conn.targetNodeId];
      if (source != null && target != null) {
        final sourceText = _truncate(source.content);
        final targetText = _truncate(target.content);
        buffer.writeln('  $sourceText → $targetText');
      }
    }

    if (mind.nodes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('--- Nodes ---');
      for (final node in mind.nodes) {
        final typeLabel = node.type.label;
        buffer.writeln('[$typeLabel] ${node.content}');
        if (node.tags.isNotEmpty) {
          buffer.writeln('  tags: ${node.tags.join(', ')}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln(
      'Exported from Seima on ${DateTime.now().toLocal().toString()}',
    );
    return buffer.toString();
  }

  Future<void> copyToClipboard(Mind mind) async {
    final package = exportMind(mind);
    await Clipboard.setData(ClipboardData(text: package.toJsonString()));
  }

  Future<String> copyPackageToClipboard(SeimaKnowledgePackage package) async {
    final json = package.toJsonString();
    await Clipboard.setData(ClipboardData(text: json));
    return json;
  }

  String _truncate(String text, [int maxLength = 60]) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
