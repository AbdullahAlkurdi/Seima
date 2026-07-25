import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/features/mind/presentation/pages/mind_library_page.dart';
import 'package:seima/features/mind/presentation/pages/mind_page.dart';
import 'package:seima/features/mind/presentation/pages/search_page.dart';

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
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}
