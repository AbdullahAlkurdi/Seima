import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

class WidgetActionHandler {
  static const _channel = MethodChannel('com.example.seima/widget');

  static const actionNewThought = 'com.example.seima.ACTION_NEW_THOUGHT';
  static const actionOpenSeima = 'com.example.seima.ACTION_OPEN_SEIMA';

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPendingAction':
        final action = call.arguments as String?;
        if (action != null) _navigate(action);
        return null;
      default:
        throw MissingPluginException();
    }
  }

  static Future<String?> getPendingAction() async {
    try {
      return await _channel.invokeMethod<String>('getPendingAction');
    } catch (_) {
      return null;
    }
  }

  static void _navigate(String action) {
    final router = GetIt.instance<GoRouter>();
    switch (action) {
      case actionNewThought:
        router.go('/quick-capture');
      case actionOpenSeima:
        router.go('/');
    }
  }

  static Future<void> handlePendingAction() async {
    final action = await getPendingAction();
    if (action == null) return;
    _navigate(action);
  }
}
