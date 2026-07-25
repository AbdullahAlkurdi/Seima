import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mindora/features/mind/data/mind_repository.dart';
import 'package:mindora/features/mind/domain/mind.dart';
import 'package:mindora/features/mind/domain/mind_node.dart';
import 'package:mindora/features/mind/domain/node_type.dart';
import 'package:mindora/features/mind/presentation/cubit/mind_cubit.dart';
import 'package:mindora/features/mind/presentation/cubit/mind_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MindRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MindRepository();
  });

  group('MindCubit', () {
    test('initial state is loading', () {
      final cubit = MindCubit(repository: repository);
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.mind, isNull);
      expect(cubit.state.canUndo, isFalse);
      expect(cubit.state.canRedo, isFalse);
    });

    blocTest<MindCubit, MindState>(
      'loadMostRecent creates new mind when none exist',
      build: () => MindCubit(repository: repository),
      act: (cubit) => cubit.loadMostRecent(),
      expect: () => [
        isA<MindState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MindState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (cubit) {
        expect(cubit.state.mind, isNotNull);
        expect(cubit.state.mind!.title, 'My Mind');
      },
    );

    group('undo/redo', () {
      blocTest<MindCubit, MindState>(
        'createNode pushes undo history',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
        },
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
          expect(cubit.state.canRedo, isFalse);
        },
      );

      blocTest<MindCubit, MindState>(
        'undo restores previous state',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes, isEmpty);
          expect(cubit.state.canRedo, isTrue);
        },
      );

      blocTest<MindCubit, MindState>(
        'redo restores state after undo',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.undo();
          cubit.redo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.length, 1);
          expect(cubit.state.canUndo, isTrue);
          expect(cubit.state.canRedo, isFalse);
        },
      );

      blocTest<MindCubit, MindState>(
        'new mutation after undo clears redo',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.undo();
          cubit.createNode(100, 100);
        },
        verify: (cubit) {
          expect(cubit.state.canRedo, isFalse);
          expect(cubit.state.mind!.nodes.length, 1);
        },
      );

      blocTest<MindCubit, MindState>(
        'undo/redo on delete',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.deleteNode(nodeId);
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.length, 1);
        },
      );

      blocTest<MindCubit, MindState>(
        'undo/redo on connection',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final nodes = cubit.state.mind!.nodes;
          cubit.startConnection(nodes[0].id);
          cubit.completeConnection(nodes[1].id);
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.connections, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'undo on title change',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.updateTitle('New Title');
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.title, 'My Mind');
        },
      );
    });

    group('node operations', () {
      blocTest<MindCubit, MindState>(
        'createNode adds a node to the mind',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(100, 200);
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.length, 1);
          expect(cubit.state.mind!.nodes.first.x, 100);
          expect(cubit.state.mind!.nodes.first.y, 200);
          expect(cubit.state.mind!.nodes.first.mindId, cubit.state.mind!.id);
        },
      );

      blocTest<MindCubit, MindState>(
        'moveNode updates node position',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(100, 200);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.moveNode(nodeId, 300, 400);
        },
        verify: (cubit) {
          final node = cubit.state.mind!.nodes.first;
          expect(node.x, 300);
          expect(node.y, 400);
        },
      );

      blocTest<MindCubit, MindState>(
        'updateNodeContent changes node content',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.updateNodeContent(nodeId, 'new content');
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.first.content, 'new content');
        },
      );

      blocTest<MindCubit, MindState>(
        'deleteNode removes node and associated connections',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final nodes = cubit.state.mind!.nodes;
          cubit.startConnection(nodes[0].id);
          cubit.completeConnection(nodes[1].id);
          cubit.deleteNode(nodes[0].id);
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.length, 1);
          expect(cubit.state.mind!.connections, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'deleteNode clears selection when deleted node is selected',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.selectNode(nodeId);
          cubit.deleteNode(nodeId);
        },
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds, isEmpty);
        },
      );
    });

    group('connection operations', () {
      blocTest<MindCubit, MindState>(
        'startConnection sets source node',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final firstId = cubit.state.mind!.nodes.first.id;
          cubit.startConnection(firstId);
        },
        verify: (cubit) {
          expect(
            cubit.state.connectionSourceNodeId,
            cubit.state.mind!.nodes.first.id,
          );
        },
      );

      blocTest<MindCubit, MindState>(
        'completeConnection creates connection between nodes',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final nodes = cubit.state.mind!.nodes;
          cubit.startConnection(nodes[0].id);
          cubit.completeConnection(nodes[1].id);
        },
        verify: (cubit) {
          expect(cubit.state.mind!.connections.length, 1);
          expect(cubit.state.connectionSourceNodeId, isNull);
        },
      );

      blocTest<MindCubit, MindState>(
        'completeConnection prevents self-connection',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.startConnection(nodeId);
          cubit.completeConnection(nodeId);
        },
        verify: (cubit) {
          expect(cubit.state.mind!.connections, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'completeConnection prevents duplicate connections',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final nodes = cubit.state.mind!.nodes;
          cubit.startConnection(nodes[0].id);
          cubit.completeConnection(nodes[1].id);
          cubit.startConnection(nodes[0].id);
          cubit.completeConnection(nodes[1].id);
        },
        verify: (cubit) {
          expect(cubit.state.mind!.connections.length, 1);
        },
      );
    });

    group('selection', () {
      blocTest<MindCubit, MindState>(
        'selectNode sets selectedNodeIds',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.selectNode(nodeId);
        },
        verify: (cubit) {
          expect(
            cubit.state.selectedNodeIds,
            contains(cubit.state.mind!.nodes.first.id),
          );
        },
      );

      blocTest<MindCubit, MindState>(
        'selectNode with null clears selection',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.selectNode(cubit.state.mind!.nodes.first.id);
          cubit.selectNode(null);
        },
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'toggleNodeSelection adds and removes from selection',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          final firstId = cubit.state.mind!.nodes[0].id;
          final secondId = cubit.state.mind!.nodes[1].id;
          cubit.toggleNodeSelection(firstId);
          cubit.toggleNodeSelection(secondId);
          cubit.toggleNodeSelection(firstId);
        },
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds.length, 1);
          expect(
            cubit.state.selectedNodeIds,
            contains(cubit.state.mind!.nodes[1].id),
          );
        },
      );

      blocTest<MindCubit, MindState>(
        'selectAll selects all nodes',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          cubit.createNode(200, 200);
          cubit.selectAll();
        },
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds.length, 3);
        },
      );

      blocTest<MindCubit, MindState>(
        'clearSelection clears all selections',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.selectAll();
          cubit.clearSelection();
        },
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'deleteSelectedNodes removes all selected nodes',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          cubit.createNode(200, 200);
          cubit.selectAll();
          cubit.deleteSelectedNodes();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes, isEmpty);
          expect(cubit.state.selectedNodeIds, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'moveSelectedNodes moves all selected nodes',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          cubit.selectAll();
          cubit.moveSelectedNodes(10, 20);
        },
        verify: (cubit) {
          final nodes = cubit.state.mind!.nodes;
          expect(nodes[0].x, 10);
          expect(nodes[0].y, 20);
          expect(nodes[1].x, 110);
          expect(nodes[1].y, 120);
        },
      );
    });

    group('tags', () {
      blocTest<MindCubit, MindState>(
        'updateNodeTags updates node tags',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.updateNodeTags(nodeId, ['flutter', 'mobile']);
        },
        verify: (cubit) {
          final node = cubit.state.mind!.nodes.first;
          expect(node.tags, contains('flutter'));
          expect(node.tags, contains('mobile'));
        },
      );

      blocTest<MindCubit, MindState>(
        'updateNodeTags pushes undo',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          final nodeId = cubit.state.mind!.nodes.first.id;
          cubit.updateNodeTags(nodeId, ['flutter']);
          cubit.undo();
        },
        verify: (cubit) {
          final node = cubit.state.mind!.nodes.first;
          expect(node.tags, isEmpty);
        },
      );
    });

    group('multi-selection undo/redo', () {
      blocTest<MindCubit, MindState>(
        'deleteSelectedNodes can be undone',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          cubit.selectAll();
          cubit.deleteSelectedNodes();
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.length, 2);
        },
      );

      blocTest<MindCubit, MindState>(
        'moveSelectedNodes can be undone',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.createNode(0, 0);
          cubit.createNode(100, 100);
          cubit.selectAll();
          cubit.moveSelectedNodes(10, 20);
          cubit.undo();
        },
        verify: (cubit) {
          final nodes = cubit.state.mind!.nodes;
          expect(nodes[0].x, 0);
          expect(nodes[0].y, 0);
          expect(nodes[1].x, 100);
          expect(nodes[1].y, 100);
        },
      );
    });

    group('save', () {
      blocTest<MindCubit, MindState>(
        'save persists mind and clears saving flag',
        build: () => MindCubit(repository: repository),
        seed: () {
          final mind = Mind(id: 'test-mind', title: 'Test');
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) async {
          await cubit.save();
        },
        verify: (cubit) {
          expect(cubit.state.isSaving, isFalse);
          expect(cubit.state.error, isNull);
        },
      );
    });

    group('node type', () {
      blocTest<MindCubit, MindState>(
        'changeNodeType updates node type',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(id: 'n1', mindId: 'm1', content: 'test');
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) => cubit.changeNodeType('n1', NodeType.task),
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.first.type, NodeType.task);
        },
      );

      blocTest<MindCubit, MindState>(
        'changeNodeType pushes undo',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(id: 'n1', mindId: 'm1', content: 'test');
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) => cubit.changeNodeType('n1', NodeType.question),
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
        },
      );
    });

    group('connection selection', () {
      blocTest<MindCubit, MindState>(
        'selectConnection sets selectedConnectionId',
        build: () => MindCubit(repository: repository),
        seed: () => const MindState().copyWith(isLoading: false),
        act: (cubit) => cubit.selectConnection('c1'),
        verify: (cubit) {
          expect(cubit.state.selectedConnectionId, 'c1');
        },
      );

      blocTest<MindCubit, MindState>(
        'selectConnection null clears selection',
        build: () => MindCubit(repository: repository),
        seed: () => const MindState().copyWith(isLoading: false),
        act: (cubit) => cubit.selectConnection(null),
        verify: (cubit) {
          expect(cubit.state.selectedConnectionId, isNull);
        },
      );

      blocTest<MindCubit, MindState>(
        'onCanvasTap clears all selections',
        build: () => MindCubit(repository: repository),
        seed: () {
          return const MindState().copyWith(
            isLoading: false,
            selectedNodeIds: {'n1'},
            selectedConnectionId: 'c1',
            connectionSourceNodeId: 'n1',
          );
        },
        act: (cubit) => cubit.onCanvasTap(),
        verify: (cubit) {
          expect(cubit.state.selectedNodeIds, isEmpty);
          expect(cubit.state.selectedConnectionId, isNull);
          expect(cubit.state.connectionSourceNodeId, isNull);
        },
      );
    });

    group('export/import', () {
      blocTest<MindCubit, MindState>(
        'exportMind returns mind data',
        build: () => MindCubit(repository: repository),
        seed: () {
          final mind = Mind(id: 'm1', title: 'Test Mind');
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) => cubit.exportMind(),
        verify: (cubit) {
          final data = cubit.exportMind();
          expect(data['version'], 1);
          expect(data['mind'], isNotNull);
          expect((data['mind'] as Map)['id'], 'm1');
        },
      );

      blocTest<MindCubit, MindState>(
        'exportMind returns empty for null mind',
        build: () => MindCubit(repository: repository),
        seed: () => const MindState().copyWith(isLoading: false),
        act: (cubit) => cubit.exportMind(),
        verify: (cubit) {
          final data = cubit.exportMind();
          expect(data, isEmpty);
        },
      );

      blocTest<MindCubit, MindState>(
        'importMind loads imported mind',
        build: () => MindCubit(repository: repository),
        seed: () => const MindState().copyWith(isLoading: false),
        act: (cubit) async {
          final data = {
            'version': 1,
            'mind': {
              'id': 'imported-1',
              'title': 'Imported Mind',
              'nodes': [],
              'connections': [],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
              'lastAccessedAt': DateTime.now().toIso8601String(),
              'tags': [],
            },
            'exportedAt': DateTime.now().toIso8601String(),
          };
          await cubit.importMind(data);
        },
        verify: (cubit) {
          expect(cubit.state.mind?.id, 'imported-1');
          expect(cubit.state.mind?.title, 'Imported Mind');
        },
      );

      blocTest<MindCubit, MindState>(
        'importMind reports error for connection with missing node reference',
        build: () => MindCubit(repository: repository),
        seed: () => const MindState().copyWith(isLoading: false),
        act: (cubit) async {
          final data = {
            'version': 1,
            'mind': {
              'id': 'imported-2',
              'title': 'Bad Import',
              'nodes': [
                {
                  'id': 'n1',
                  'mindId': 'imported-2',
                  'type': 'text',
                  'content': 'Existing',
                  'x': 0,
                  'y': 0,
                  'createdAt': DateTime.now().toIso8601String(),
                  'updatedAt': DateTime.now().toIso8601String(),
                },
              ],
              'connections': [
                {
                  'id': 'c1',
                  'mindId': 'imported-2',
                  'sourceNodeId': 'n1',
                  'targetNodeId': 'nonexistent',
                  'sourceSide': 'right',
                  'targetSide': 'left',
                },
              ],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
              'lastAccessedAt': DateTime.now().toIso8601String(),
              'tags': [],
            },
            'exportedAt': DateTime.now().toIso8601String(),
          };
          await cubit.importMind(data);
        },
        verify: (cubit) {
          expect(cubit.state.error, isNotNull);
          expect(cubit.state.error!.message, contains('Invalid import'));
        },
      );
    });

    group('drag undo grouping', () {
      blocTest<MindCubit, MindState>(
        'moveNode during drag does not push undo',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'test',
            x: 0,
            y: 0,
          );
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) {
          cubit.beginNodeDrag();
          cubit.moveNode('n1', 100, 200);
          cubit.moveNode('n1', 200, 300);
        },
        verify: (cubit) {
          expect(cubit.state.canUndo, isFalse);
          expect(cubit.state.mind!.nodes.first.x, 200);
          expect(cubit.state.mind!.nodes.first.y, 300);
        },
      );

      blocTest<MindCubit, MindState>(
        'endNodeDrag pushes single undo entry',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'test',
            x: 0,
            y: 0,
          );
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) {
          cubit.beginNodeDrag();
          cubit.moveNode('n1', 100, 200);
          cubit.moveNode('n1', 150, 250);
          cubit.endNodeDrag();
        },
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
          expect(cubit.state.mind!.nodes.first.x, 150);
          expect(cubit.state.mind!.nodes.first.y, 250);
        },
      );

      blocTest<MindCubit, MindState>(
        'moveNode without drag pushes undo immediately',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'test',
            x: 0,
            y: 0,
          );
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) => cubit.moveNode('n1', 100, 200),
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
        },
      );
    });

    group('undo batching', () {
      blocTest<MindCubit, MindState>(
        'beginBatchUndo suppresses undo pushes until endBatchUndo',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(
            id: 'n1',
            mindId: 'm1',
            content: 'original',
            tags: [],
          );
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) {
          cubit.beginBatchUndo();
          cubit.updateNodeContent('n1', 'batched content');
          cubit.updateNodeTags('n1', ['tag1', 'tag2']);
          cubit.changeNodeType('n1', NodeType.task);
          cubit.endBatchUndo();
        },
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
          expect(cubit.state.canRedo, isFalse);
          expect(cubit.state.undoHistory.length, 1);
          final restored = cubit.state.undoHistory.first;
          expect(restored.nodes.first.content, 'original');
          expect(restored.nodes.first.tags, isEmpty);
          expect(restored.nodes.first.type, NodeType.text);
        },
      );

      blocTest<MindCubit, MindState>(
        'endBatchUndo pushes single undo for batch of create + tag + content',
        build: () => MindCubit(repository: repository),
        act: (cubit) async {
          await cubit.loadMostRecent();
          cubit.beginBatchUndo();
          cubit.createNode(0, 0);
          final nid = cubit.state.mind!.nodes.last.id;
          cubit.updateNodeTags(nid, ['ai']);
          cubit.updateNodeContent(nid, 'AI suggested');
          cubit.endBatchUndo();
        },
        verify: (cubit) {
          expect(cubit.state.canUndo, isTrue);
          expect(cubit.state.undoHistory.length, 1);
          expect(cubit.state.mind!.nodes.length, 1);
          expect(cubit.state.mind!.nodes.first.content, 'AI suggested');
          expect(cubit.state.mind!.nodes.first.tags, contains('ai'));
        },
      );

      blocTest<MindCubit, MindState>(
        'undo batching reverts all changes in one undo',
        build: () => MindCubit(repository: repository),
        seed: () {
          final node = MindNode(id: 'n1', mindId: 'm1', content: 'before');
          final mind = Mind(id: 'm1', nodes: [node]);
          return const MindState().copyWith(mind: mind, isLoading: false);
        },
        act: (cubit) {
          cubit.beginBatchUndo();
          cubit.updateNodeContent('n1', 'changed');
          cubit.updateNodeTags('n1', ['test']);
          cubit.endBatchUndo();
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.mind!.nodes.first.content, 'before');
          expect(cubit.state.mind!.nodes.first.tags, isEmpty);
        },
      );
    });
  });
}
