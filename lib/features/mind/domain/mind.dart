import 'dart:convert';
import 'mind_node.dart';
import 'mind_connection.dart';

class Mind {
  static const currentSchemaVersion = 1;

  final String id;
  final String title;
  final String? description;
  final List<MindNode> nodes;
  final List<MindConnection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastAccessedAt;
  final int schemaVersion;
  final int sequenceNumber;

  Mind({
    required this.id,
    this.title = 'Untitled',
    this.description,
    this.nodes = const [],
    this.connections = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    this.schemaVersion = currentSchemaVersion,
    this.sequenceNumber = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       lastAccessedAt = lastAccessedAt ?? DateTime.now();

  Mind copyWith({
    String? title,
    String? description,
    List<MindNode>? nodes,
    List<MindConnection>? connections,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    bool updateTimestamp = false,
    int? sequenceNumber,
  }) {
    return Mind(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      createdAt: createdAt,
      updatedAt: updateTimestamp
          ? DateTime.now()
          : (updatedAt ?? this.updatedAt),
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      schemaVersion: schemaVersion,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'connections': connections.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastAccessedAt': lastAccessedAt.toIso8601String(),
    'sequenceNumber': sequenceNumber,
  };

  factory Mind.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int? ?? currentSchemaVersion;
    return Mind(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map((n) => MindNode.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      connections:
          (json['connections'] as List<dynamic>?)
              ?.map((c) => MindConnection.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : (json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : DateTime.now()),
      schemaVersion: version,
      sequenceNumber: json['sequenceNumber'] as int? ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Mind.fromJsonString(String source) =>
      Mind.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mind &&
          id == other.id &&
          title == other.title &&
          nodes.length == other.nodes.length &&
          connections.length == other.connections.length &&
          sequenceNumber == other.sequenceNumber;

  @override
  int get hashCode => Object.hash(id, title, sequenceNumber);

  @override
  String toString() => 'Mind(id: $id, title: $title, nodes: ${nodes.length})';
}
