import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/mind/domain/node_type.dart';

void main() {
  group('NodeType', () {
    test('has all values', () {
      expect(NodeType.values, hasLength(4));
      expect(
        NodeType.values,
        containsAll([
          NodeType.text,
          NodeType.task,
          NodeType.question,
          NodeType.idea,
        ]),
      );
    });

    test('text has correct name and label', () {
      expect(NodeType.text.name, 'text');
      expect(NodeType.text.label, 'Text');
    });

    test('task has correct name and label', () {
      expect(NodeType.task.name, 'task');
      expect(NodeType.task.label, 'Task');
    });

    test('question has correct name and label', () {
      expect(NodeType.question.name, 'question');
      expect(NodeType.question.label, 'Question');
    });

    test('idea has correct name and label', () {
      expect(NodeType.idea.name, 'idea');
      expect(NodeType.idea.label, 'Idea');
    });

    test('all types have icons', () {
      for (final type in NodeType.values) {
        expect(type.icon, isNotNull);
      }
    });

    test('all types return colors', () {
      const colorScheme = ColorScheme.light();
      for (final type in NodeType.values) {
        expect(type.color(colorScheme: colorScheme), isNotNull);
      }
    });
  });
}
