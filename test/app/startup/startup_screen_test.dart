import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seima/app/startup/startup_screen.dart';

void main() {
  group('StartupScreen', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: StartupScreen(child: const Text('Main Content'))),
      );
      await tester.pump();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('shows Seima icon during animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: StartupScreen(child: const Text('Main Content'))),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('animation completes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: StartupScreen(child: const Text('Main Content'))),
      );

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('hides startup after animation completes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupScreen(
            duration: const Duration(milliseconds: 100),
            child: const Text('Visible'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Visible'), findsOneWidget);
    });
  });
}
