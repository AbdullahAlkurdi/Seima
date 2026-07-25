sealed class AIProposal {
  final String reason;

  const AIProposal({required this.reason});
}

class NewNodeProposal extends AIProposal {
  final String content;
  final List<String> tags;

  const NewNodeProposal({
    required this.content,
    this.tags = const [],
    required super.reason,
  });
}

class ConnectionProposal extends AIProposal {
  final String sourceNodeId;
  final String targetNodeId;

  const ConnectionProposal({
    required this.sourceNodeId,
    required this.targetNodeId,
    required super.reason,
  });
}
