import 'package:seima/core/errors/app_exception.dart';

class Failure {
  const Failure({required this.message, this.exception});

  final String message;
  final AppException? exception;

  factory Failure.unknown([String? message, AppException? exception]) {
    return Failure(
      message: message ?? 'An unknown error occurred',
      exception: exception,
    );
  }

  factory Failure.cache([String? message, AppException? exception]) {
    return Failure(
      message: message ?? 'A cache error occurred',
      exception: exception,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          exception == other.exception;

  @override
  int get hashCode => Object.hash(message, exception);

  @override
  String toString() => 'Failure: $message';
}
