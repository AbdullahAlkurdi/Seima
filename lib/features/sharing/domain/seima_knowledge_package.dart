import 'dart:convert';

class PackageNode {
  final String id;
  final String type;
  final String content;
  final List<String> tags;
  final double x;
  final double y;
  final double width;
  final double height;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  const PackageNode({
    required this.id,
    this.type = 'text',
    this.content = '',
    this.tags = const [],
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 80,
    this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (content.isNotEmpty) 'content': content,
    if (tags.isNotEmpty) 'tags': tags,
    'position': {'x': x, 'y': y},
    'dimensions': {'width': width, 'height': height},
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (metadata.isNotEmpty) 'metadata': metadata,
  };

  factory PackageNode.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || id is! String || id.isEmpty) {
      throw ArgumentError('PackageNode missing required field: id');
    }
    final position = json['position'] as Map<String, dynamic>?;
    final dimensions = json['dimensions'] as Map<String, dynamic>?;
    return PackageNode(
      id: id,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      x: (position?['x'] as num?)?.toDouble() ?? 0,
      y: (position?['y'] as num?)?.toDouble() ?? 0,
      width: (dimensions?['width'] as num?)?.toDouble() ?? 200,
      height: (dimensions?['height'] as num?)?.toDouble() ?? 80,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class PackageConnection {
  final String id;
  final String sourceId;
  final String targetId;
  final String type;
  final String? label;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;

  const PackageConnection({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.type = 'directed',
    this.label,
    this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'source_id': sourceId,
    'target_id': targetId,
    if (type != 'directed') 'type': type,
    if (label != null) 'label': label,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (metadata.isNotEmpty) 'metadata': metadata,
  };

  factory PackageConnection.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final sourceId = json['source_id'];
    final targetId = json['target_id'];
    if (id == null || id is! String || id.isEmpty) {
      throw ArgumentError('PackageConnection missing required field: id');
    }
    if (sourceId == null || sourceId is! String || sourceId.isEmpty) {
      throw ArgumentError(
        'PackageConnection missing required field: source_id',
      );
    }
    if (targetId == null || targetId is! String || targetId.isEmpty) {
      throw ArgumentError(
        'PackageConnection missing required field: target_id',
      );
    }
    return PackageConnection(
      id: id,
      sourceId: sourceId,
      targetId: targetId,
      type: json['type'] as String? ?? 'directed',
      label: json['label'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class PackageMind {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const PackageMind({
    required this.id,
    this.title = 'Untitled',
    this.description,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    if (category != null) 'category': category,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (tags.isNotEmpty) 'tags': tags,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };

  factory PackageMind.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || id is! String || id.isEmpty) {
      throw ArgumentError('PackageMind missing required field: id');
    }
    return PackageMind(
      id: id,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class PackageProvenance {
  final DateTime exportedAt;
  final String exportedBy;
  final String sourceApp;
  final String? notes;

  PackageProvenance({
    DateTime? exportedAt,
    this.exportedBy = 'seima_export',
    this.sourceApp = 'seima',
    this.notes,
  }) : exportedAt = exportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'exported_at': exportedAt.toIso8601String(),
    'exported_by': exportedBy,
    'source_app': sourceApp,
    if (notes != null) 'notes': notes,
  };

  factory PackageProvenance.fromJson(Map<String, dynamic> json) {
    return PackageProvenance(
      exportedAt: json['exported_at'] != null
          ? DateTime.parse(json['exported_at'] as String)
          : DateTime.now(),
      exportedBy: json['exported_by'] as String? ?? 'seima_export',
      sourceApp: json['source_app'] as String? ?? 'seima',
      notes: json['notes'] as String?,
    );
  }
}

class SeimaKnowledgePackage {
  static const String schema = 'seima_knowledge';
  static const int currentVersion = 1;

  final int version;
  final DateTime createdAt;
  final String sourceApp;
  final PackageMind? mind;
  final List<PackageNode> nodes;
  final List<PackageConnection> connections;
  final PackageProvenance? provenance;

  SeimaKnowledgePackage({
    this.version = currentVersion,
    DateTime? createdAt,
    this.sourceApp = 'seima',
    this.mind,
    this.nodes = const [],
    this.connections = const [],
    this.provenance,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'schema': schema,
    'seima_knowledge_version': version,
    'created_at': createdAt.toIso8601String(),
    'source_app': sourceApp,
    if (mind != null) 'mind': mind!.toJson(),
    if (nodes.isNotEmpty) 'nodes': nodes.map((n) => n.toJson()).toList(),
    if (connections.isNotEmpty)
      'connections': connections.map((c) => c.toJson()).toList(),
    if (provenance != null) 'provenance': provenance!.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory SeimaKnowledgePackage.fromJson(Map<String, dynamic> json) {
    final schemaId = json['schema'] as String?;
    if (schemaId != schema) {
      throw ArgumentError(
        'Invalid schema: expected "$schema", got "${schemaId ?? 'null'}"',
      );
    }
    final version = json['seima_knowledge_version'] as int? ?? 1;
    if (version > currentVersion) {
      throw ArgumentError(
        'Unsupported format version $version. '
        'This version of Seima supports up to version $currentVersion.',
      );
    }

    final nodesJson = json['nodes'] as List<dynamic>?;
    final connectionsJson = json['connections'] as List<dynamic>?;

    final nodes = nodesJson != null
        ? nodesJson
              .map((n) => PackageNode.fromJson(n as Map<String, dynamic>))
              .toList()
        : <PackageNode>[];

    final connections = connectionsJson != null
        ? connectionsJson
              .map((c) => PackageConnection.fromJson(c as Map<String, dynamic>))
              .toList()
        : <PackageConnection>[];

    return SeimaKnowledgePackage(
      version: version,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : DateTime.now(),
      sourceApp: json['source_app'] as String? ?? 'unknown',
      mind: json['mind'] != null
          ? PackageMind.fromJson(json['mind'] as Map<String, dynamic>)
          : null,
      nodes: nodes,
      connections: connections,
      provenance: json['provenance'] != null
          ? PackageProvenance.fromJson(
              json['provenance'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  factory SeimaKnowledgePackage.fromJsonString(String source) {
    return SeimaKnowledgePackage.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}
