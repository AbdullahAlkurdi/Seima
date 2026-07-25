import 'package:seima/features/ai/domain/ai_context.dart';
import 'package:seima/features/mind/domain/mind.dart';

class MindContextBuilder {
  final int maxNodes;
  final int maxNodeContentLength;

  const MindContextBuilder({
    this.maxNodes = 50,
    this.maxNodeContentLength = 200,
  });

  AIContext build(Mind mind) {
    final nodes = mind.nodes
        .map(
          (n) => AIContextNode(
            id: n.id,
            content: n.content,
            tags: List.from(n.tags),
          ),
        )
        .toList();

    final connections = mind.connections
        .map(
          (c) => AIContextConnection(
            sourceNodeId: c.sourceNodeId,
            targetNodeId: c.targetNodeId,
          ),
        )
        .toList();

    return AIContext(
      title: mind.title,
      description: mind.description,
      nodes: nodes,
      connections: connections,
      nodeCount: nodes.length,
      connectionCount: connections.length,
    );
  }

  String toPrompt(AIContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Mind Map: "${context.title}"');
    if (context.description != null && context.description!.isNotEmpty) {
      buffer.writeln('Description: ${context.description}');
    }
    buffer.writeln();

    if (context.nodes.isEmpty) {
      buffer.writeln('This mind map has no nodes yet.');
      return buffer.toString();
    }

    final nodesToShow = context.nodes.take(maxNodes).toList();

    buffer.writeln('Nodes:');
    for (final node in nodesToShow) {
      buffer.write('- [${node.id}]');
      if (node.content.isNotEmpty) {
        final truncated = node.content.length > maxNodeContentLength
            ? '${node.content.substring(0, maxNodeContentLength)}...'
            : node.content;
        buffer.write(' "$truncated"');
      } else {
        buffer.write(' (empty)');
      }
      if (node.tags.isNotEmpty) {
        buffer.write(' [tags: ${node.tags.join(', ')}]');
      }
      buffer.writeln();
    }
    if (context.nodes.length > maxNodes) {
      buffer.writeln('- ... and ${context.nodes.length - maxNodes} more nodes');
    }
    buffer.writeln();

    if (context.connections.isEmpty) {
      buffer.writeln('No connections between nodes.');
    } else {
      buffer.writeln('Connections:');
      for (final conn in context.connections) {
        buffer.writeln('- ${conn.sourceNodeId} → ${conn.targetNodeId}');
      }
    }

    return buffer.toString();
  }

  AIContext buildTruncated(Mind mind, {int maxNodes = 50}) {
    final allNodes = mind.nodes
        .map(
          (n) => AIContextNode(
            id: n.id,
            content: n.content.isNotEmpty ? n.content : '',
            tags: List.from(n.tags),
          ),
        )
        .toList();

    final prioritized = _prioritizeNodes(allNodes, mind.connections, maxNodes);

    final relevantIds = prioritized.map((n) => n.id).toSet();
    final connections = mind.connections
        .where(
          (c) =>
              relevantIds.contains(c.sourceNodeId) &&
              relevantIds.contains(c.targetNodeId),
        )
        .map(
          (c) => AIContextConnection(
            sourceNodeId: c.sourceNodeId,
            targetNodeId: c.targetNodeId,
          ),
        )
        .toList();

    return AIContext(
      title: mind.title,
      description: mind.description,
      nodes: prioritized,
      connections: connections,
      nodeCount: mind.nodes.length,
      connectionCount: mind.connections.length,
    );
  }

  List<AIContextNode> _prioritizeNodes(
    List<AIContextNode> nodes,
    List<dynamic> connections,
    int maxNodes,
  ) {
    if (nodes.length <= maxNodes) return nodes;

    final connectionCount = <String, int>{};
    for (final node in nodes) {
      connectionCount[node.id] = 0;
    }
    for (final conn in connections) {
      connectionCount[conn.sourceNodeId] =
          (connectionCount[conn.sourceNodeId] ?? 0) + 1;
      connectionCount[conn.targetNodeId] =
          (connectionCount[conn.targetNodeId] ?? 0) + 1;
    }

    final sorted = List<AIContextNode>.from(nodes)
      ..sort((a, b) {
        final connDiff =
            (connectionCount[b.id] ?? 0) - (connectionCount[a.id] ?? 0);
        if (connDiff != 0) return connDiff;
        return b.content.length.compareTo(a.content.length);
      });

    return sorted.take(maxNodes).toList();
  }
}
