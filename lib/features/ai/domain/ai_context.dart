class AIContextNode {
  final String id;
  final String content;
  final List<String> tags;

  const AIContextNode({
    required this.id,
    required this.content,
    this.tags = const [],
  });
}

class AIContextConnection {
  final String sourceNodeId;
  final String targetNodeId;

  const AIContextConnection({
    required this.sourceNodeId,
    required this.targetNodeId,
  });
}

class AIContext {
  final String title;
  final String? description;
  final List<AIContextNode> nodes;
  final List<AIContextConnection> connections;
  final int nodeCount;
  final int connectionCount;

  const AIContext({
    required this.title,
    this.description,
    required this.nodes,
    required this.connections,
    required this.nodeCount,
    required this.connectionCount,
  });
}
