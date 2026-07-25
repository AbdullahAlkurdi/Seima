import 'package:mindora/core/errors/app_exception.dart';

class AIFailure {
  const AIFailure({required this.message, this.exception});

  final String message;
  final AppException? exception;

  factory AIFailure.network([String? message, AppException? exception]) {
    return AIFailure(
      message: message ?? 'Network error. Check your connection and try again.',
      exception: exception,
    );
  }

  factory AIFailure.timeout([AppException? exception]) {
    return AIFailure(
      message: 'The request timed out. Please try again.',
      exception: exception,
    );
  }

  factory AIFailure.api([String? message, AppException? exception]) {
    return AIFailure(
      message: message ?? 'The AI service returned an error.',
      exception: exception,
    );
  }

  factory AIFailure.config([String? message]) {
    return AIFailure(
      message:
          message ??
          'AI is not configured. Set your API endpoint and key in AI Settings.',
    );
  }

  factory AIFailure.rateLimit([AppException? exception]) {
    return AIFailure(
      message: 'Rate limit exceeded. Please wait a moment and try again.',
      exception: exception,
    );
  }

  factory AIFailure.parse([String? message, AppException? exception]) {
    return AIFailure(
      message: message ?? 'Could not understand the AI response.',
      exception: exception,
    );
  }

  factory AIFailure.model([String? message, AppException? exception]) {
    return AIFailure(
      message:
          message ??
          'Local model is not available. Download a model in AI settings.',
      exception: exception,
    );
  }

  factory AIFailure.unknown([String? message, AppException? exception]) {
    return AIFailure(
      message: message ?? 'An unexpected error occurred.',
      exception: exception,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AIFailure: $message';
}
