import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:seima/app/router/app_router.dart';
import 'package:seima/app/theme/app_theme.dart';
import 'package:seima/core/sharing/share_handler.dart';
import 'package:seima/features/ai/data/ai_service.dart';
import 'package:seima/features/ai/data/llm_runtime.dart';
import 'package:seima/features/ai/data/llm_ai_service.dart';
import 'package:seima/features/ai/data/model_manager.dart';
import 'package:seima/features/ai/data/process_llm_runtime.dart';
import 'package:seima/features/ai/presentation/cubit/ai_cubit.dart';
import 'package:seima/features/mind/data/mind_repository.dart';
import 'package:seima/features/mind/presentation/cubit/mind_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/mind_library_cubit.dart';
import 'package:seima/features/mind/presentation/cubit/search_cubit.dart';
import 'package:seima/features/sharing/data/export_service.dart';
import 'package:seima/features/sharing/data/import_service.dart';
import 'package:seima/features/sharing/presentation/cubit/import_cubit.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<ThemeController>(() => ThemeController());
  sl.registerLazySingleton<GoRouter>(() => AppRouter.createRouter());
  sl.registerLazySingleton<MindRepository>(() => MindRepository());
  sl.registerLazySingleton<ShareHandler>(() => ShareHandler());
  sl.registerLazySingleton<ExportService>(() => ExportService());
  sl.registerLazySingleton<ImportService>(() => ImportService());

  final llmRuntime = ProcessLLMRuntime();
  final modelManager = ModelManager.default_;
  final llmService = LLMAIService(llmRuntime: llmRuntime);

  sl.registerLazySingleton<LocalLLMRuntime>(() => llmRuntime);
  sl.registerLazySingleton<ModelManager>(() => modelManager);
  sl.registerLazySingleton<AIService>(() => llmService);

  sl.registerFactory<MindCubit>(
    () => MindCubit(repository: sl<MindRepository>()),
  );
  sl.registerFactory<MindLibraryCubit>(
    () => MindLibraryCubit(repository: sl<MindRepository>()),
  );
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(repository: sl<MindRepository>()),
  );
  sl.registerFactory<AICubit>(
    () => AICubit(
      aiService: sl<AIService>(),
      llmRuntime: sl<LocalLLMRuntime>(),
      modelManager: sl<ModelManager>(),
    ),
  );
  sl.registerFactory<ImportCubit>(
    () => ImportCubit(
      importService: sl<ImportService>(),
      repository: sl<MindRepository>(),
    ),
  );
}
