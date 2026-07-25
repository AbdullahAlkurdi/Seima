import 'package:flutter_test/flutter_test.dart';
import 'package:seima/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('creates with message only', () {
      final e = AppException(message: 'Test error');
      expect(e.message, 'Test error');
      expect(e.code, isNull);
      expect(e.originalError, isNull);
    });

    test('creates with message and code', () {
      final e = AppException(message: 'Not found', code: '404');
      expect(e.message, 'Not found');
      expect(e.code, '404');
    });

    test('toString includes message and code', () {
      final e = AppException(message: 'Error', code: 'ERR1');
      expect(e.toString(), contains('Error'));
      expect(e.toString(), contains('ERR1'));
    });
  });
}
