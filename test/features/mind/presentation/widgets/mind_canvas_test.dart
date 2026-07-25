import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/mind/domain/mind.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/presentation/widgets/mind_canvas.dart';

Widget wrapCanvas(MindCanvas canvas) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: 800, height: 600, child: canvas),
      ),
    ),
  );
}

void main() {
  testWidgets('renders node content on canvas', (tester) async {
    final node = MindNode(
      id: 'n1',
      mindId: 'm1',
      content: 'Test Node',
      x: 0,
      y: 0,
    );
    final mind = Mind(id: 'm1', nodes: [node]);
    await tester.pumpWidget(
      wrapCanvas(
        MindCanvas(
          mind: mind,
          selectedNodeIds: const {},
          connectionSourceNodeId: null,
          onNodeTap: (_) {},
          onNodeDoubleTap: (_) {},
          onNodeDelete: (_) {},
          onStartConnection: (_) {},
          onNodeMove: (_, _, _) {},
          onConnectionTap: (_) {},
          onCanvasTap: () {},
        ),
      ),
    );
    expect(find.text('Test Node'), findsOneWidget);
  });

  testWidgets('renders multiple nodes', (tester) async {
    final node1 = MindNode(
      id: 'n1',
      mindId: 'm1',
      content: 'Node 1',
      x: 0,
      y: 0,
    );
    final node2 = MindNode(
      id: 'n2',
      mindId: 'm1',
      content: 'Node 2',
      x: 200,
      y: 200,
    );
    final mind = Mind(id: 'm1', nodes: [node1, node2]);
    await tester.pumpWidget(
      wrapCanvas(
        MindCanvas(
          mind: mind,
          selectedNodeIds: const {},
          connectionSourceNodeId: null,
          onNodeTap: (_) {},
          onNodeDoubleTap: (_) {},
          onNodeDelete: (_) {},
          onStartConnection: (_) {},
          onNodeMove: (_, _, _) {},
          onConnectionTap: (_) {},
          onCanvasTap: () {},
        ),
      ),
    );
    expect(find.text('Node 1'), findsOneWidget);
    expect(find.text('Node 2'), findsOneWidget);
  });

  testWidgets('shows placeholder for empty node', (tester) async {
    final node = MindNode(id: 'n1', mindId: 'm1', x: 0, y: 0);
    final mind = Mind(id: 'm1', nodes: [node]);
    await tester.pumpWidget(
      wrapCanvas(
        MindCanvas(
          mind: mind,
          selectedNodeIds: const {},
          connectionSourceNodeId: null,
          onNodeTap: (_) {},
          onNodeDoubleTap: (_) {},
          onNodeDelete: (_) {},
          onStartConnection: (_) {},
          onNodeMove: (_, _, _) {},
          onConnectionTap: (_) {},
          onCanvasTap: () {},
        ),
      ),
    );
    expect(find.text('New Text Node'), findsOneWidget);
  });

  testWidgets(
    'rectangle selection with Shift+drag selects intersecting nodes',
    (tester) async {
      final node1 = MindNode(
        id: 'n1',
        mindId: 'm1',
        content: 'Node 1',
        x: 0,
        y: 0,
        width: 200,
        height: 80,
      );
      final node2 = MindNode(
        id: 'n2',
        mindId: 'm1',
        content: 'Node 2',
        x: 300,
        y: 300,
        width: 200,
        height: 80,
      );
      final mind = Mind(id: 'm1', nodes: [node1, node2]);

      Set<String>? selectionResult;

      await tester.pumpWidget(
        wrapCanvas(
          MindCanvas(
            mind: mind,
            selectedNodeIds: const {},
            connectionSourceNodeId: null,
            onNodeTap: (_) {},
            onNodeDoubleTap: (_) {},
            onNodeDelete: (_) {},
            onStartConnection: (_) {},
            onNodeMove: (_, _, _) {},
            onConnectionTap: (_) {},
            onCanvasTap: () {},
            onSelectionChanged: (ids) => selectionResult = ids,
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);

      await tester.timedDragFrom(
        const Offset(0, 0),
        const Offset(250, 150),
        const Duration(milliseconds: 100),
      );

      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(selectionResult, isNotNull);
      expect(selectionResult!.length, 1);
      expect(selectionResult, contains('n1'));
    },
  );

  testWidgets('rectangle selection without Shift does not trigger selection', (
    tester,
  ) async {
    final node = MindNode(id: 'n1', mindId: 'm1', content: 'Node', x: 0, y: 0);
    final mind = Mind(id: 'm1', nodes: [node]);

    bool callbackCalled = false;

    await tester.pumpWidget(
      wrapCanvas(
        MindCanvas(
          mind: mind,
          selectedNodeIds: const {},
          connectionSourceNodeId: null,
          onNodeTap: (_) {},
          onNodeDoubleTap: (_) {},
          onNodeDelete: (_) {},
          onStartConnection: (_) {},
          onNodeMove: (_, _, _) {},
          onConnectionTap: (_) {},
          onCanvasTap: () {},
          onSelectionChanged: (_) => callbackCalled = true,
        ),
      ),
    );

    // Drag without Shift
    await tester.timedDragFrom(
      const Offset(0, 0),
      const Offset(100, 100),
      const Duration(milliseconds: 100),
    );

    expect(callbackCalled, isFalse);
  });
}
