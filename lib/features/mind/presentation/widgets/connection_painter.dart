import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seima/features/mind/domain/mind_connection.dart';
import 'package:seima/features/mind/domain/mind_node.dart';

class ConnectionPainter extends CustomPainter {
  final List<MindConnection> connections;
  final List<MindNode> nodes;
  final Set<String> nodeIds;
  final String? selectedConnectionId;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    required this.nodeIds,
    this.selectedConnectionId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final conn in connections) {
      final source = nodeMap[conn.sourceNodeId];
      final target = nodeMap[conn.targetNodeId];
      if (source == null || target == null) continue;

      final isSelected = conn.id == selectedConnectionId;
      _drawBezierConnection(canvas, source, target, isSelected);
    }
  }

  void _drawBezierConnection(
    Canvas canvas,
    MindNode source,
    MindNode target,
    bool isSelected,
  ) {
    final sourceCenter = Offset(
      source.x + source.width / 2,
      source.y + source.height / 2,
    );
    final targetCenter = Offset(
      target.x + target.width / 2,
      target.y + target.height / 2,
    );

    final dy = targetCenter.dy - sourceCenter.dy;
    final dx = targetCenter.dx - sourceCenter.dx;
    final isLeftToRight = dx >= 0;

    final controlOffset = (dx.abs() + dy.abs()) * 0.3;
    final cp1 = Offset(
      sourceCenter.dx + (isLeftToRight ? controlOffset : -controlOffset),
      sourceCenter.dy,
    );
    final cp2 = Offset(
      targetCenter.dx + (isLeftToRight ? -controlOffset : controlOffset),
      targetCenter.dy,
    );

    final path = Path()
      ..moveTo(sourceCenter.dx, sourceCenter.dy)
      ..cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        targetCenter.dx,
        targetCenter.dy,
      );

    final paint = Paint()
      ..color = isSelected
          ? Colors.orange.withValues(alpha: 0.9)
          : Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = isSelected ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    _drawArrowhead(canvas, path, targetCenter);
  }

  void _drawArrowhead(Canvas canvas, Path path, Offset tip) {
    final metric = path.computeMetrics().single;
    final tangent = metric.getTangentForOffset(metric.length);
    if (tangent == null) return;

    final direction = tangent.vector;
    final angle = math.atan2(direction.dy, direction.dx);
    const arrowSize = 10.0;
    const arrowAngle = 0.5;

    final left = Offset(
      tip.dx - arrowSize * math.cos(angle - arrowAngle),
      tip.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    final right = Offset(
      tip.dx - arrowSize * math.cos(angle + arrowAngle),
      tip.dy - arrowSize * math.sin(angle + arrowAngle),
    );

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) =>
      connections != oldDelegate.connections ||
      nodes != oldDelegate.nodes ||
      selectedConnectionId != oldDelegate.selectedConnectionId;
}
