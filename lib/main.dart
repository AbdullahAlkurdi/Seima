import 'package:flutter/material.dart';
import 'package:seima/app/di.dart';
import 'package:seima/app/app.dart';
import 'package:seima/core/widget/widget_action_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetActionHandler.init();
  initDependencies();
  runApp(const SeimaApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetActionHandler.handlePendingAction();
  });
}
