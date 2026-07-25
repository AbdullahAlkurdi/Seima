import 'package:flutter/material.dart';

enum NodeType {
  text,
  task,
  question,
  idea;

  String get label {
    switch (this) {
      case text:
        return 'Text';
      case task:
        return 'Task';
      case question:
        return 'Question';
      case idea:
        return 'Idea';
    }
  }

  IconData get icon {
    switch (this) {
      case text:
        return Icons.text_fields;
      case task:
        return Icons.check_circle_outline;
      case question:
        return Icons.help_outline;
      case idea:
        return Icons.lightbulb_outline;
    }
  }

  Color color({required ColorScheme colorScheme, bool isDark = false}) {
    switch (this) {
      case text:
        return colorScheme.primary;
      case task:
        return colorScheme.tertiary;
      case question:
        return colorScheme.secondary;
      case idea:
        return colorScheme.error;
    }
  }
}
