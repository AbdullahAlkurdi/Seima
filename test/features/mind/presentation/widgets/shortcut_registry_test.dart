import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/features/mind/presentation/widgets/shortcut_registry.dart';

void main() {
  group('buildMindShortcutBindings', () {
    test('returns map with all expected shortcut activators', () {
      bool undoCalled = false;
      bool redoCalled = false;
      bool selectAllCalled = false;
      bool escapeCalled = false;
      bool deleteCalled = false;

      final bindings = buildMindShortcutBindings(
        onUndo: () => undoCalled = true,
        onRedo: () => redoCalled = true,
        onSelectAll: () => selectAllCalled = true,
        onEscape: () => escapeCalled = true,
        onDelete: () => deleteCalled = true,
      );

      expect(bindings.length, 6);

      final keys = bindings.keys.toList();
      expect(
        keys.whereType<SingleActivator>().any(
          (k) =>
              k.trigger == LogicalKeyboardKey.keyZ &&
              k.control == true &&
              k.shift == false &&
              k.alt == false,
        ),
        isTrue,
      );
      expect(
        keys.whereType<SingleActivator>().any(
          (k) => k.trigger == LogicalKeyboardKey.keyY && k.control == true,
        ),
        isTrue,
      );
      expect(
        keys.whereType<SingleActivator>().any(
          (k) => k.trigger == LogicalKeyboardKey.keyA && k.control == true,
        ),
        isTrue,
      );
      expect(
        keys.whereType<SingleActivator>().any(
          (k) => k.trigger == LogicalKeyboardKey.escape,
        ),
        isTrue,
      );
      expect(
        keys.whereType<SingleActivator>().any(
          (k) => k.trigger == LogicalKeyboardKey.delete,
        ),
        isTrue,
      );
      expect(
        keys.whereType<SingleActivator>().any(
          (k) => k.trigger == LogicalKeyboardKey.backspace,
        ),
        isTrue,
      );

      for (final entry in bindings.entries) {
        entry.value();
      }
      expect(undoCalled, isTrue);
      expect(redoCalled, isTrue);
      expect(selectAllCalled, isTrue);
      expect(escapeCalled, isTrue);
      expect(deleteCalled, isTrue);
    });

    test('delete and backspace map to same callback', () {
      int deleteCount = 0;

      final bindings = buildMindShortcutBindings(
        onUndo: () {},
        onRedo: () {},
        onSelectAll: () {},
        onEscape: () {},
        onDelete: () => deleteCount++,
      );

      final deleteKeys = bindings.keys
          .whereType<SingleActivator>()
          .where((k) => k.trigger == LogicalKeyboardKey.delete)
          .toList();
      final backspaceKeys = bindings.keys
          .whereType<SingleActivator>()
          .where((k) => k.trigger == LogicalKeyboardKey.backspace)
          .toList();

      expect(deleteKeys.length, 1);
      expect(backspaceKeys.length, 1);

      bindings[deleteKeys.first]?.call();
      bindings[backspaceKeys.first]?.call();

      expect(deleteCount, 2);
    });
  });
}
