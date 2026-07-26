import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/features/ai/presentation/pages/ai_analysis_page.dart';
import 'package:seima/features/mind/presentation/pages/mind_library_page.dart';
import 'package:seima/features/mind/presentation/pages/mind_page.dart';
import 'package:seima/features/mind/presentation/pages/search_page.dart';
import 'package:seima/features/quick_capture/presentation/pages/quick_capture_page.dart';
import 'package:seima/features/settings/presentation/pages/ai_model_management_page.dart';
import 'package:seima/features/settings/presentation/pages/export_import_page.dart';
import 'package:seima/features/settings/presentation/pages/settings_page.dart';
import 'package:seima/features/sharing/presentation/pages/import_preview_page.dart';
import 'package:seima/features/sharing/presentation/pages/export_page.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'library',
          builder: (context, state) => const MindLibraryPage(),
        ),
        GoRoute(
          path: '/mind/:id',
          name: 'mindById',
          builder: (context, state) =>
              MindPage(mindId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/quick-capture',
          name: 'quickCapture',
          builder: (context, state) => const QuickCapturePage(),
        ),
        GoRoute(
          path: '/ai-analysis/:id',
          name: 'aiAnalysis',
          builder: (context, state) =>
              AIAnalysisPage(mindId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/export-import',
          name: 'exportImport',
          builder: (context, state) => const ExportImportPage(),
        ),
        GoRoute(
          path: '/export',
          name: 'export',
          builder: (context, state) => const ExportPage(),
        ),
        GoRoute(
          path: '/export/:id',
          name: 'exportMind',
          builder: (context, state) =>
              ExportPage(mindId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/import',
          name: 'import',
          builder: (context, state) => const ImportPreviewPage(),
        ),
        GoRoute(
          path: '/import-preview',
          name: 'importPreview',
          builder: (context, state) {
            final content = state.uri.queryParameters['content'];
            return ImportPreviewPage(initialContent: content);
          },
        ),
        GoRoute(
          path: '/ai-settings',
          name: 'aiSettings',
          builder: (context, state) => const AIModelManagementPage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}
