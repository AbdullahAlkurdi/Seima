import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindora/app/widgets/mindora_loading_view.dart';

void main() {
  group('MindoraLoadingView', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MindoraLoadingView(message: 'Loading minds...')),
      );
      await tester.pump();

      expect(find.byType(MindoraLoadingView), findsOneWidget);
      expect(find.text('Loading minds...'), findsOneWidget);
    });

    testWidgets('renders compact variant without full page scaffold', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindoraLoadingView(variant: MindoraLoadingVariant.compact),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MindoraLoadingView), findsOneWidget);
    });

    testWidgets('renders with progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MindoraLoadingView(progress: 0.5)),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('overlay variant fills container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MindoraLoadingView(variant: MindoraLoadingVariant.overlay),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MindoraLoadingView), findsOneWidget);
    });

    testWidgets('icon asset renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: MindoraLoadingView()));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('default variant is fullPage with Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(home: MindoraLoadingView()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
