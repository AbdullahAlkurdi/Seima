import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:seima/app/di.dart';
import 'package:seima/app/app.dart';
import 'package:seima/core/sharing/share_handler.dart';
import 'package:seima/core/widget/widget_action_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetActionHandler.init();
  initDependencies();
  runApp(const SeimaApp());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    WidgetActionHandler.handlePendingAction();
    final shareHandler = GetIt.instance<ShareHandler>();
    await shareHandler.init();
    if (shareHandler.hasPendingContent) {
      final router = GetIt.instance<GoRouter>();
      final content = shareHandler.pendingContent;
      final source = shareHandler.pendingSource;
      shareHandler.clearPending();
      if (content != null) {
        router.go(
          '/import-preview?content=${Uri.encodeComponent(content)}&source=$source',
        );
      }
    }
  });
}
