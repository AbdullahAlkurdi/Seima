import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<ShortcutActivator, VoidCallback> buildMindShortcutBindings({
  required VoidCallback onUndo,
  required VoidCallback onRedo,
  required VoidCallback onSelectAll,
  required VoidCallback onEscape,
  required VoidCallback onDelete,
}) {
  return {
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): onUndo,
    SingleActivator(LogicalKeyboardKey.keyY, control: true): onRedo,
    SingleActivator(LogicalKeyboardKey.keyA, control: true): onSelectAll,
    SingleActivator(LogicalKeyboardKey.escape): onEscape,
    SingleActivator(LogicalKeyboardKey.delete): onDelete,
    SingleActivator(LogicalKeyboardKey.backspace): onDelete,
  };
}
