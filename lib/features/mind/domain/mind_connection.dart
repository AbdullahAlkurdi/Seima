class MindConnection {
  final String id;
  final String mindId;
  final String sourceNodeId;
  final String targetNodeId;
  final DateTime createdAt;

  MindConnection({
    required this.id,
    required this.mindId,
    required this.sourceNodeId,
    required this.targetNodeId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MindConnection copyWith({
    String? id,
    String? mindId,
    String? sourceNodeId,
    String? targetNodeId,
  }) {
    return MindConnection(
      id: id ?? this.id,
      mindId: mindId ?? this.mindId,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mindId': mindId,
    'sourceNodeId': sourceNodeId,
    'targetNodeId': targetNodeId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MindConnection.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final mindId = json['mindId'] as String?;
    final source = json['sourceNodeId'] as String?;
    final target = json['targetNodeId'] as String?;
    if (id == null || mindId == null || source == null || target == null) {
      throw ArgumentError(
        'MindConnection JSON missing required fields: id=$id, mindId=$mindId, source=$source, target=$target',
      );
    }
    return MindConnection(
      id: id,
      mindId: mindId,
      sourceNodeId: source,
      targetNodeId: target,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindConnection &&
          id == other.id &&
          mindId == other.mindId &&
          sourceNodeId == other.sourceNodeId &&
          targetNodeId == other.targetNodeId;

  @override
  int get hashCode => Object.hash(id, mindId, sourceNodeId, targetNodeId);

  @override
  String toString() => 'MindConnection(id: $id, $sourceNodeId → $targetNodeId)';
}
