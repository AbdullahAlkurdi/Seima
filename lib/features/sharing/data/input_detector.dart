import 'dart:convert';

enum InputFormat { seimaPackage, plainText, json, unknown }

class DetectedInput {
  final InputFormat format;
  final String content;
  final String? sourceHint;

  const DetectedInput({
    required this.format,
    required this.content,
    this.sourceHint,
  });
}

class InputDetector {
  static const _seimaSchema = 'seima_knowledge';

  DetectedInput detect(String input, {String? sourceHint}) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return DetectedInput(format: InputFormat.unknown, content: input);
    }

    if (_looksLikeJson(trimmed)) {
      if (_isSeimaPackage(trimmed)) {
        return DetectedInput(
          format: InputFormat.seimaPackage,
          content: input,
          sourceHint: sourceHint,
        );
      }
      return DetectedInput(
        format: InputFormat.json,
        content: input,
        sourceHint: sourceHint,
      );
    }

    return DetectedInput(
      format: InputFormat.plainText,
      content: input,
      sourceHint: sourceHint,
    );
  }

  bool _looksLikeJson(String input) {
    final trimmed = input.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  bool _isSeimaPackage(String input) {
    try {
      final parsed = _parseJsonSafe(input);
      if (parsed is Map<String, dynamic>) {
        return parsed['schema'] == _seimaSchema;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Object? _parseJsonSafe(String input) {
    return jsonDecode(input);
  }

  static DetectedInput detectFormat(String input, {String? sourceHint}) {
    final detector = InputDetector();
    return detector.detect(input, sourceHint: sourceHint);
  }
}
