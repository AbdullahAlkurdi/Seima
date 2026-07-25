import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/domain/mind_node.dart';
import 'package:seima/features/mind/presentation/widgets/canvas_node.dart';
import 'package:seima/features/mind/presentation/widgets/connection_painter.dart';

class MindCanvas extends StatefulWidget {
  final Mind mind;
  final Set<String> selectedNodeIds;
  final String? selectedConnectionId;
  final String? connectionSourceNodeId;
  final Rect? visibleRect;
  final void Function(String id) onNodeTap;
  final void Function(String id) onNodeDoubleTap;
  final void Function(String id) onNodeDelete;
  final void Function(String id) onStartConnection;
  final void Function(String id, double dx, double dy) onNodeMove;
  final void Function()? onNodeDragStart;
  final void Function()? onNodeDragEnd;
  final void Function(String id) onConnectionTap;
  final void Function() onCanvasTap;
  final void Function(Set<String> selectedIds)? onSelectionChanged;
  final void Function(bool isActive)? onSelectionActive;

  const MindCanvas({
    super.key,
    required this.mind,
    required this.selectedNodeIds,
    this.selectedConnectionId,
    this.connectionSourceNodeId,
    this.visibleRect,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onNodeDelete,
    required this.onStartConnection,
    required this.onNodeMove,
    this.onNodeDragStart,
    this.onNodeDragEnd,
    required this.onConnectionTap,
    required this.onCanvasTap,
    this.onSelectionChanged,
    this.onSelectionActive,
  });

  @override
  State<MindCanvas> createState() => _MindCanvasState();
}

class _MindCanvasState extends State<MindCanvas> {
  Offset? _selectionStart;
  Offset? _selectionEnd;
  bool _isSelecting = false;

  void _onPointerDown(PointerDownEvent event) {
    if (!HardwareKeyboard.instance.isShiftPressed) return;
    setState(() {
      _isSelecting = true;
      _selectionStart = event.position;
      _selectionEnd = event.position;
    });
    widget.onSelectionActive?.call(true);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isSelecting) return;
    setState(() {
      _selectionEnd = event.position;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isSelecting) return;
    _finalizeSelection();
    setState(() {
      _isSelecting = false;
      _selectionStart = null;
      _selectionEnd = null;
    });
    widget.onSelectionActive?.call(false);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_isSelecting) return;
    setState(() {
      _isSelecting = false;
      _selectionStart = null;
      _selectionEnd = null;
    });
    widget.onSelectionActive?.call(false);
  }

  void _finalizeSelection() {
    if (_selectionStart == null || _selectionEnd == null) return;
    final raw = Rect.fromPoints(_selectionStart!, _selectionEnd!);
    final rect = Rect.fromLTRB(
      math.min(raw.left, raw.right),
      math.min(raw.top, raw.bottom),
      math.max(raw.left, raw.right),
      math.max(raw.top, raw.bottom),
    );
    if (rect.isEmpty) return;
    final selected = <String>{};
    for (final node in widget.mind.nodes) {
      final nodeRect = Rect.fromLTWH(node.x, node.y, node.width, node.height);
      if (rect.overlaps(nodeRect)) {
        selected.add(node.id);
      }
    }
    if (selected.isNotEmpty) {
      widget.onSelectionChanged?.call(selected);
    }
  }

  Rect _computeBounds() {
    if (widget.mind.nodes.isEmpty) return Rect.fromLTWH(0, 0, 4000, 4000);
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final node in widget.mind.nodes) {
      if (node.x < minX) minX = node.x;
      if (node.y < minY) minY = node.y;
      if (node.x + node.width > maxX) maxX = node.x + node.width;
      if (node.y + node.height > maxY) maxY = node.y + node.height;
    }
    final padding = 500.0;
    return Rect.fromLTWH(
      0,
      0,
      (maxX - minX + padding * 2).clamp(4000, double.infinity),
      (maxY - minY + padding * 2).clamp(3000, double.infinity),
    );
  }

  bool _isVisible(MindNode node, Rect? viewport) {
    if (viewport == null) return true;
    final nodeRect = Rect.fromLTWH(node.x, node.y, node.width, node.height);
    return viewport.overlaps(nodeRect);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _computeBounds();
    final nodeMap = {for (final n in widget.mind.nodes) n.id: n};

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: () {
          if (HardwareKeyboard.instance.isShiftPressed) return;
          final center = Offset(bounds.width / 2, bounds.height / 2);
          final connectionId = _findConnectionAtPoint(center, nodeMap);
          if (connectionId != null) {
            widget.onConnectionTap(connectionId);
          } else {
            widget.onCanvasTap();
          }
        },
        child: SizedBox.fromSize(
          size: Size(bounds.width, bounds.height),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(bounds.width, bounds.height),
                painter: ConnectionPainter(
                  connections: widget.mind.connections,
                  nodes: widget.mind.nodes,
                  nodeIds: widget.mind.nodes.map((n) => n.id).toSet(),
                  selectedConnectionId: widget.selectedConnectionId,
                ),
              ),
              ...widget.mind.nodes
                  .where((node) => _isVisible(node, widget.visibleRect))
                  .map((node) {
                    return Positioned(
                      left: node.x,
                      top: node.y,
                      child: CanvasNodeWidget(
                        node: node,
                        isSelected: widget.selectedNodeIds.contains(node.id),
                        isConnectionSource:
                            node.id == widget.connectionSourceNodeId,
                        onTap: () => widget.onNodeTap(node.id),
                        onDoubleTap: () => widget.onNodeDoubleTap(node.id),
                        onDelete: () => widget.onNodeDelete(node.id),
                        onStartConnection: () =>
                            widget.onStartConnection(node.id),
                        onMove: (dx, dy) => widget.onNodeMove(node.id, dx, dy),
                        onDragStart: widget.onNodeDragStart,
                        onDragEnd: widget.onNodeDragEnd,
                      ),
                    );
                  }),
              if (_isSelecting &&
                  _selectionStart != null &&
                  _selectionEnd != null)
                CustomPaint(
                  size: Size(bounds.width, bounds.height),
                  painter: _SelectionRectPainter(
                    start: _selectionStart!,
                    end: _selectionEnd!,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _findConnectionAtPoint(Offset point, Map<String, MindNode> nodeMap) {
    const hitRadius = 8.0;
    for (final conn in widget.mind.connections) {
      final source = nodeMap[conn.sourceNodeId];
      final target = nodeMap[conn.targetNodeId];
      if (source == null || target == null) continue;
      final mid = Offset(
        (source.x + source.width / 2 + target.x + target.width / 2) / 2,
        (source.y + source.height / 2 + target.y + target.height / 2) / 2,
      );
      if ((point - mid).distance < hitRadius) return conn.id;
    }
    return null;
  }
}

class _SelectionRectPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _SelectionRectPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final raw = Rect.fromPoints(start, end);
    final rect = Rect.fromLTRB(
      math.min(raw.left, raw.right),
      math.min(raw.top, raw.bottom),
      math.max(raw.left, raw.right),
      math.max(raw.top, raw.bottom),
    );
    if (rect.isEmpty) return;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_SelectionRectPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color;
  }
}
