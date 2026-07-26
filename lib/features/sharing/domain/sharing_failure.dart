class SharingFailure {
  final String message;
  final String? code;
  final Object? originalError;

  const SharingFailure({required this.message, this.code, this.originalError});

  factory SharingFailure.invalidFormat([String? detail]) {
    return SharingFailure(
      message: detail ?? 'The input could not be recognized as a valid format',
      code: 'invalid_format',
    );
  }

  factory SharingFailure.unsupportedVersion(int version) {
    return SharingFailure(
      message:
          'Format version $version is not supported by this version of Seima',
      code: 'unsupported_version',
    );
  }

  factory SharingFailure.parseError([String? detail]) {
    return SharingFailure(
      message: detail ?? 'Failed to parse the input',
      code: 'parse_error',
    );
  }

  factory SharingFailure.invalidSchema([String? detail]) {
    return SharingFailure(
      message: detail ?? 'The input has an invalid schema identifier',
      code: 'invalid_schema',
    );
  }

  factory SharingFailure.missingRequiredField(String field) {
    return SharingFailure(
      message: 'Missing required field: $field',
      code: 'missing_field',
    );
  }

  factory SharingFailure.fileError([String? detail]) {
    return SharingFailure(
      message: detail ?? 'Failed to read or write the file',
      code: 'file_error',
    );
  }

  factory SharingFailure.ioError(Object error) {
    return SharingFailure(
      message: 'An I/O error occurred: $error',
      code: 'io_error',
      originalError: error,
    );
  }

  factory SharingFailure.unknown([String? detail]) {
    return SharingFailure(
      message: detail ?? 'An unknown error occurred',
      code: 'unknown',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingFailure && message == other.message && code == other.code;

  @override
  int get hashCode => Object.hash(message, code);

  @override
  String toString() => 'SharingFailure($code): $message';
}
