import 'package:flutter_test/flutter_test.dart';
import 'package:seima/core/errors/app_exception.dart';
import 'package:seima/core/errors/failures.dart';

void main() {
  group('Failure', () {
    test('creates with message', () {
      final f = Failure(message: 'Something went wrong');
      expect(f.message, 'Something went wrong');
      expect(f.exception, isNull);
    });

    test('unknown factory creates default message', () {
      final f = Failure.unknown();
      expect(f.message, 'An unknown error occurred');
    });

    test('cache factory creates default message', () {
      final f = Failure.cache();
      expect(f.message, 'A cache error occurred');
    });

    test('can include exception', () {
      final e = AppException(message: 'Original error');
      final f = Failure.unknown(null, e);
      expect(f.exception, e);
    });
  });
}
