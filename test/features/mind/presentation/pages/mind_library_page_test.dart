import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seima/app/router/app_router.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/domain/mind.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:seima/features/mind/presentation/pages/mind_library_page.dart';

Widget createTestApp(Widget child) {
  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(
          path: '/mind/:id',
          builder: (_, state) => Scaffold(
            body: Center(child: Text('Mind ${state.pathParameters['id']}')),
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Search placeholder'))),
        ),
      ],
    ),
  );
}

void main() {
  late MindRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MindRepository();
    final sl = GetIt.instance;
    if (!sl.isRegistered<ThemeController>()) {
      sl.registerLazySingleton<ThemeController>(() => ThemeController());
    }
    if (!sl.isRegistered<MindRepository>()) {
      sl.registerLazySingleton<MindRepository>(() => repository);
    }
    if (!sl.isRegistered<GoRouter>()) {
      sl.registerLazySingleton<GoRouter>(() => AppRouter.createRouter());
    }
    if (!sl.isRegistered<MindLibraryCubit>()) {
      sl.registerFactory<MindLibraryCubit>(
        () => MindLibraryCubit(repository: sl<MindRepository>()),
      );
    }
  });

  testWidgets('MindLibraryPage renders without ProviderNotFoundException', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();

    expect(find.byType(MindLibraryPage), findsOneWidget);
  });

  testWidgets('MindLibraryPage shows empty state when no minds exist', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome to Seima'), findsOneWidget);
    expect(find.text('Create your first mind to get started.'), findsOneWidget);
    expect(find.text('Create Your First Mind'), findsOneWidget);
  });

  testWidgets('MindLibraryPage search icon is present', (tester) async {
    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('MindLibraryPage theme toggle icon is present', (tester) async {
    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('MindLibraryPage FAB creates a mind in repository', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('New Mind'), findsOneWidget);

    await tester.tap(find.text('New Mind'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final minds = await repository.loadAll();
    expect(minds.length, 1);
    expect(minds.first.title, 'My Mind');
  });

  testWidgets('MindLibraryPage shows created mind in list', (tester) async {
    await repository.save(Mind(id: 'test-1', title: 'Test Mind'));

    await tester.pumpWidget(createTestApp(const MindLibraryPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Test Mind'), findsOneWidget);
    expect(find.text('New Mind'), findsOneWidget);
  });
}
