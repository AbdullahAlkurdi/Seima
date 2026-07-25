import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seima/app/router/app_router.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/features/mind/data/id_provider.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/search_cubit.dart';
import 'package:seima/features/mind/presentation/pages/search_page.dart';

Widget createTestApp(Widget child) {
  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Library')),
        ),
        GoRoute(path: '/search', builder: (_, _) => child),
        GoRoute(
          path: '/mind/:id',
          builder: (_, state) => Scaffold(
            body: Center(child: Text('Mind ${state.pathParameters['id']}')),
          ),
        ),
      ],
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final sl = GetIt.instance;
    if (!sl.isRegistered<MindRepository>()) {
      sl.registerLazySingleton<MindRepository>(() => MindRepository());
    }
    if (!sl.isRegistered<GoRouter>()) {
      sl.registerLazySingleton<GoRouter>(() => AppRouter.createRouter());
    }
    if (!sl.isRegistered<SearchCubit>()) {
      sl.registerFactory<SearchCubit>(
        () => SearchCubit(repository: sl<MindRepository>()),
      );
    }
  });

  tearDown(() {
    final sl = GetIt.instance;
    sl.reset(dispose: false);
  });

  testWidgets('SearchPage renders without ProviderNotFoundException', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();

    expect(find.byType(SearchPage), findsOneWidget);
  });

  testWidgets('SearchPage shows initial empty state', (tester) async {
    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Search across all your minds'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('SearchPage clear button appears after typing', (tester) async {
    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'test');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.clear), findsWidgets);
  });

  testWidgets('SearchPage shows no results for non-existent query', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'nonexistent');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('No results for'), findsOneWidget);
  });

  testWidgets('SearchPage search finds a mind by title', (tester) async {
    final repository = GetIt.instance<MindRepository>();
    final mind = Mind(id: generateId(), title: 'Test Mind');
    await repository.save(mind);

    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Test');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Test Mind'), findsWidgets);
  });

  testWidgets('SearchPage tap on result navigates to mind', (tester) async {
    final repository = GetIt.instance<MindRepository>();
    final mind = Mind(id: 'nav-test-1', title: 'Navigation Test');
    await repository.save(mind);

    await tester.pumpWidget(createTestApp(const SearchPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Navigation');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final resultTile = find.text('Navigation Test');
    await tester.tap(resultTile.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mind nav-test-1'), findsOneWidget);
  });
}
