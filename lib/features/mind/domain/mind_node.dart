import 'node_type.dart';

class MindNode {
  final String id;
  final String mindId;
  final NodeType type;
  final String content;
  final List<String> tags;
  final double x;
  final double y;
  final double width;
  final double height;
  final DateTime createdAt;
  final DateTime updatedAt;

  MindNode({
    required this.id,
    required this.mindId,
    this.type = NodeType.text,
    this.content = '',
    this.tags = const [],
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 80,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  MindNode copyWith({
    String? id,
    NodeType? type,
    String? content,
    List<String>? tags,
    double? x,
    double? y,
    double? width,
    double? height,
    DateTime? updatedAt,
  }) {
    return MindNode(
      id: id ?? this.id,
      mindId: mindId,
      type: type ?? this.type,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  double get contentHeight {
    const lineHeight = 20.0;
    const padding = 32.0;
    if (content.isEmpty) return 40;
    final lineCount = content.split('\n').length;
    final wrappedLines = (content.length / 40).ceil();
    return (lineCount > wrappedLines ? lineCount : wrappedLines) * lineHeight +
        padding +
        (tags.isNotEmpty ? 24.0 : 0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mindId': mindId,
    'type': type.name,
    'content': content,
    if (tags.isNotEmpty) 'tags': tags,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MindNode.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final mindId = json['mindId'] as String?;
    if (id == null || mindId == null) {
      throw ArgumentError(
        'MindNode JSON missing required fields: id=$id, mindId=$mindId',
      );
    }
    final typeStr = json['type'] as String?;
    final type = NodeType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => NodeType.text,
    );
    return MindNode(
      id: id,
      mindId: mindId,
      type: type,
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 200,
      height: (json['height'] as num?)?.toDouble() ?? 80,
      createdAt: json['createdAt'] != null
          ? _tryParseDate(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? _tryParseDate(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  static DateTime _tryParseDate(String date) {
    return DateTime.tryParse(date) ?? DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindNode &&
          id == other.id &&
          mindId == other.mindId &&
          type == other.type &&
          content == other.content &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode =>
      Object.hash(id, mindId, type, content, x, y, width, height);

  @override
  String toString() => 'MindNode(id: $id, content: $content, x: $x, y: $y)';
}
