import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/node_type.dart';
import 'package:seima/features/mind/data/id_provider.dart';
import 'package:seima/features/sharing/domain/seima_knowledge_package.dart';
import 'package:seima/features/sharing/domain/sharing_failure.dart';
import 'package:seima/features/sharing/data/input_detector.dart';

class ImportPreview {
  final String title;
  final String sourceType;
  final int nodeCount;
  final int connectionCount;
  final List<String> detectedTags;
  final List<String> warnings;
  final List<String> errors;
  final SeimaKnowledgePackage package;
  final String? sourceDescription;

  const ImportPreview({
    required this.title,
    required this.sourceType,
    required this.nodeCount,
    required this.connectionCount,
    this.detectedTags = const [],
    this.warnings = const [],
    this.errors = const [],
    required this.package,
    this.sourceDescription,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isValid => !hasErrors;
}

class ImportResult {
  final Mind mind;
  final bool isNew;

  const ImportResult({required this.mind, required this.isNew});
}

class ImportService {
  Future<ImportPreview> previewFromPackage(SeimaKnowledgePackage pkg) {
    final warnings = <String>[];
    final errors = <String>[];
    final tags = <String>{};

    if (pkg.nodes.isEmpty && pkg.connections.isEmpty) {
      warnings.add('The package contains no nodes or connections');
    }

    final nodeIds = <String>{};
    for (final node in pkg.nodes) {
      if (nodeIds.contains(node.id)) {
        warnings.add('Duplicate node ID found: ${node.id}');
      }
      nodeIds.add(node.id);
      tags.addAll(node.tags);
    }

    for (final conn in pkg.connections) {
      if (!nodeIds.contains(conn.sourceId)) {
        errors.add(
          'Connection references non-existent source node: ${conn.sourceId}',
        );
      }
      if (!nodeIds.contains(conn.targetId)) {
        errors.add(
          'Connection references non-existent target node: ${conn.targetId}',
        );
      }
    }

    final title = pkg.mind?.title ?? pkg.provenance?.sourceApp ?? 'Untitled';

    return Future.value(
      ImportPreview(
        title: title,
        sourceType: 'Seima Knowledge Package',
        nodeCount: pkg.nodes.length,
        connectionCount: pkg.connections.length,
        detectedTags: tags.toList(),
        warnings: warnings,
        errors: errors,
        package: pkg,
        sourceDescription: pkg.mind?.description,
      ),
    );
  }

  Future<ImportPreview> previewFromFile(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        throw SharingFailure.fileError('File not found: $path');
      }
      final content = await file.readAsString();
      return previewFromString(content, sourceHint: path);
    } on SharingFailure {
      rethrow;
    } catch (e) {
      throw SharingFailure.fileError('Failed to read file: $e');
    }
  }

  Future<ImportPreview> previewFromString(
    String content, {
    String? sourceHint,
  }) async {
    final detector = InputDetector();
    final detected = detector.detect(content, sourceHint: sourceHint);
    return _previewFromDetected(detected);
  }

  Future<ImportPreview> previewFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) {
      throw SharingFailure.invalidFormat('Clipboard is empty');
    }
    return previewFromString(text, sourceHint: 'clipboard');
  }

  Future<ImportPreview> _previewFromDetected(DetectedInput detected) async {
    switch (detected.format) {
      case InputFormat.seimaPackage:
        return _previewSeimaPackage(detected.content);
      case InputFormat.json:
        return _previewGenericJson(detected.content);
      case InputFormat.plainText:
        return _previewPlainText(detected.content);
      case InputFormat.unknown:
        throw SharingFailure.invalidFormat();
    }
  }

  Future<ImportPreview> _previewSeimaPackage(String content) async {
    try {
      final pkg = SeimaKnowledgePackage.fromJsonString(content);
      return previewFromPackage(pkg);
    } on ArgumentError catch (e) {
      throw SharingFailure.parseError(e.message);
    } catch (e) {
      throw SharingFailure.parseError('Failed to parse Seima package: $e');
    }
  }

  Future<ImportPreview> _previewGenericJson(String content) async {
    try {
      final json = jsonDecode(content);
      if (json is Map<String, dynamic> && json.containsKey('mind')) {
        // Legacy Seima format (version 1 export)
        final mindJson = json['mind'] as Map<String, dynamic>;
        final mind = Mind.fromJson(mindJson);
        final pkg = _mindToPackage(mind);
        return previewFromPackage(pkg);
      }
    } catch (_) {}
    throw SharingFailure.invalidFormat(
      'JSON content is not a recognized Seima format',
    );
  }

  Future<ImportPreview> _previewPlainText(String content) async {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final pkg = SeimaKnowledgePackage(
      mind: PackageMind(id: generateId(), title: 'Imported Text'),
      nodes: lines.asMap().entries.map((entry) {
        return PackageNode(
          id: generateId(),
          content: entry.value,
          y: entry.key * 100.0,
        );
      }).toList(),
      provenance: PackageProvenance(notes: 'Imported from plain text'),
    );

    return ImportPreview(
      title: 'Imported Text',
      sourceType: 'Plain Text',
      nodeCount: lines.length,
      connectionCount: 0,
      package: pkg,
      warnings: lines.length > 100
          ? ['Large text (>100 lines) will create many nodes']
          : [],
    );
  }

  SeimaKnowledgePackage _mindToPackage(Mind mind) {
    final exportService = _ExportServiceHelper();
    return exportService.exportMind(mind);
  }

  Future<ImportResult> executeAsNewMind(ImportPreview preview) async {
    final pkg = preview.package;
    final mind = _packageToMind(pkg);
    return ImportResult(mind: mind, isNew: true);
  }

  Future<ImportResult> executeMergeIntoMind(
    ImportPreview preview,
    Mind targetMind,
  ) async {
    final pkg = preview.package;
    final nodeIdMap = <String, String>{};

    var mergedNodes = List<MindNode>.from(targetMind.nodes);
    var mergedConnections = List<MindConnection>.from(targetMind.connections);

    for (final pkgNode in pkg.nodes) {
      final newId = generateId();
      nodeIdMap[pkgNode.id] = newId;
      final type = NodeType.values.firstWhere(
        (t) => t.name == pkgNode.type,
        orElse: () => NodeType.text,
      );
      mergedNodes.add(
        MindNode(
          id: newId,
          mindId: targetMind.id,
          type: type,
          content: pkgNode.content,
          tags: List<String>.from(pkgNode.tags),
          x: pkgNode.x + 50,
          y: pkgNode.y + 50,
          width: pkgNode.width,
          height: pkgNode.height,
          createdAt: pkgNode.createdAt ?? DateTime.now(),
          updatedAt: pkgNode.updatedAt ?? DateTime.now(),
        ),
      );
    }

    for (final pkgConn in pkg.connections) {
      final newSourceId = nodeIdMap[pkgConn.sourceId];
      final newTargetId = nodeIdMap[pkgConn.targetId];
      if (newSourceId != null && newTargetId != null) {
        mergedConnections.add(
          MindConnection(
            id: generateId(),
            mindId: targetMind.id,
            sourceNodeId: newSourceId,
            targetNodeId: newTargetId,
            createdAt: pkgConn.createdAt ?? DateTime.now(),
          ),
        );
      }
    }

    final mergedMind = targetMind.copyWith(
      nodes: mergedNodes,
      connections: mergedConnections,
      updateTimestamp: true,
    );

    return ImportResult(mind: mergedMind, isNew: false);
  }

  Mind _packageToMind(SeimaKnowledgePackage pkg) {
    final newMindId = generateId();
    final nodeIdMap = <String, String>{};

    final nodes = pkg.nodes.map((pkgNode) {
      final newId = generateId();
      nodeIdMap[pkgNode.id] = newId;
      final type = NodeType.values.firstWhere(
        (t) => t.name == pkgNode.type,
        orElse: () => NodeType.text,
      );
      return MindNode(
        id: newId,
        mindId: newMindId,
        type: type,
        content: pkgNode.content,
        tags: List<String>.from(pkgNode.tags),
        x: pkgNode.x,
        y: pkgNode.y,
        width: pkgNode.width,
        height: pkgNode.height,
        createdAt: pkgNode.createdAt ?? DateTime.now(),
        updatedAt: pkgNode.updatedAt ?? DateTime.now(),
      );
    }).toList();

    final connections = pkg.connections.map((pkgConn) {
      final newSourceId = nodeIdMap[pkgConn.sourceId];
      final newTargetId = nodeIdMap[pkgConn.targetId];
      if (newSourceId == null || newTargetId == null) {
        throw SharingFailure.invalidFormat(
          'Connection references non-existent node: '
          '${pkgConn.sourceId} → ${pkgConn.targetId}',
        );
      }
      return MindConnection(
        id: generateId(),
        mindId: newMindId,
        sourceNodeId: newSourceId,
        targetNodeId: newTargetId,
        createdAt: pkgConn.createdAt ?? DateTime.now(),
      );
    }).toList();

    return Mind(
      id: newMindId,
      title: pkg.mind?.title ?? 'Imported Mind',
      description: pkg.mind?.description,
      category: pkg.mind?.category,
      nodes: nodes,
      connections: connections,
    );
  }
}

class _ExportServiceHelper {
  SeimaKnowledgePackage exportMind(Mind mind) {
    final nodeMap = <String, PackageNode>{};

    for (final node in mind.nodes) {
      nodeMap[node.id] = PackageNode(
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
    }

    final pkgConnections = mind.connections.map((conn) {
      return PackageConnection(
        id: conn.id,
        sourceId: conn.sourceNodeId,
        targetId: conn.targetNodeId,
        createdAt: conn.createdAt,
      );
    }).toList();

    return SeimaKnowledgePackage(
      mind: PackageMind(
        id: mind.id,
        title: mind.title,
        description: mind.description,
        category: mind.category,
        createdAt: mind.createdAt,
        updatedAt: mind.updatedAt,
      ),
      nodes: nodeMap.values.toList(),
      connections: pkgConnections,
      provenance: PackageProvenance(
        exportedBy: 'seima_export',
        sourceApp: 'seima',
      ),
    );
  }
}
