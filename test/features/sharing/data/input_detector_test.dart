import 'package:flutter_test/flutter_test.dart';
import 'package:seima/features/sharing/data/input_detector.dart';

void main() {
  group('InputDetector', () {
    late InputDetector detector;

    setUp(() {
      detector = InputDetector();
    });

    group('detect', () {
      test('detects empty input as unknown', () {
        final result = detector.detect('');
        expect(result.format, InputFormat.unknown);
      });

      test('detects whitespace-only input as unknown', () {
        final result = detector.detect('   \n  \t  ');
        expect(result.format, InputFormat.unknown);
      });

      test('detects seima package JSON', () {
        final input =
            '{"schema": "seima_knowledge", "seima_knowledge_version": 1}';
        final result = detector.detect(input);
        expect(result.format, InputFormat.seimaPackage);
      });

      test('detects non-seima JSON as json', () {
        final input = '{"name": "test", "value": 42}';
        final result = detector.detect(input);
        expect(result.format, InputFormat.json);
      });

      test('detects JSON array as json', () {
        final input = '[1, 2, 3]';
        final result = detector.detect(input);
        expect(result.format, InputFormat.json);
      });

      test('detects plain text', () {
        final input = 'Hello, this is plain text.\nWith multiple lines.';
        final result = detector.detect(input);
        expect(result.format, InputFormat.plainText);
      });

      test('preserves content', () {
        final input = 'Some content here';
        final result = detector.detect(input);
        expect(result.content, input);
      });

      test('preserves source hint', () {
        final result = detector.detect('text', sourceHint: 'clipboard');
        expect(result.sourceHint, 'clipboard');
      });
    });

    group('detectFormat static', () {
      test('static method works correctly', () {
        final result = InputDetector.detectFormat(
          '{"schema": "seima_knowledge"}',
        );
        expect(result.format, InputFormat.seimaPackage);
      });
    });
  });
}
