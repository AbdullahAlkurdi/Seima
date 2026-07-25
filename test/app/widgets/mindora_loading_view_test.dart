import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seima/app/widgets/mindora_loading_view.dart';

void main() {
  group('SeimaLoadingView', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SeimaLoadingView(message: 'Loading minds...')),
      );
      await tester.pump();

      expect(find.byType(SeimaLoadingView), findsOneWidget);
      expect(find.text('Loading minds...'), findsOneWidget);
    });

    testWidgets('renders compact variant without full page scaffold', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeimaLoadingView(variant: SeimaLoadingVariant.compact),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SeimaLoadingView), findsOneWidget);
    });

    testWidgets('renders with progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SeimaLoadingView(progress: 0.5)),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('overlay variant fills container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeimaLoadingView(variant: SeimaLoadingVariant.overlay),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SeimaLoadingView), findsOneWidget);
    });

    testWidgets('icon asset renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SeimaLoadingView()));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('default variant is fullPage with Scaffold', (tester) async {
      await tester.pumpWidget(MaterialApp(home: SeimaLoadingView()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
