import 'package:flutter/services.dart';

class ShareHandler {
  static const _channel = MethodChannel('com.seima/sharing');

  String? _pendingContent;
  String? _pendingSource;

  String? get pendingContent => _pendingContent;
  String? get pendingSource => _pendingSource;
  bool get hasPendingContent => _pendingContent != null;

  Future<void> init() async {
    try {
      final result = await _channel.invokeMethod<String>('getPendingShare');
      if (result != null && result.isNotEmpty) {
        final parts = result.split('|||');
        if (parts.length >= 2) {
          _pendingContent = parts[0];
          _pendingSource = parts[1];
        } else {
          _pendingContent = result;
          _pendingSource = 'share';
        }
      }
    } on MissingPluginException {
      // Not available on this platform
    } catch (_) {}
  }

  void clearPending() {
    _pendingContent = null;
    _pendingSource = null;
  }
}
