import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:naira_sms_pulse/core/database/category_entity.dart';
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/database/transaction_entity.dart';
import 'package:naira_sms_pulse/core/helpers/sms_miner_service.dart';
import 'package:naira_sms_pulse/core/network/local/shared_preferences_service.dart';
import 'package:naira_sms_pulse/features/auth/data/datasources/auth_service.dart';
import 'package:naira_sms_pulse/features/auth/data/repository/auth_repo_impli.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/cubit/navnavidation_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:naira_sms_pulse/features/onboarding/data/repository/onboarding_repo_imple.dart';
import 'package:naira_sms_pulse/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // 👈 ADD THIS LINE

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. 🛑 AWAIT THESE! (Critical Fix)
  // These must finish before the app can run.
  await _initSharedPreferences();
  await _initIsarDb();

  // 2. These are synchronous (Instant), so no await needed
  await _initSupabase(); // Usually Supabase.initialize is async, check main.dart
  _initAuth();
  _initSplash();
  _initOnBoarding();
  _intiSmsMiningService();
  _initNavNavigation();
  _initHome();
}

_initSupabase() {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

_initOnBoarding() {
  sl.registerLazySingleton<OnboardingDataSource>(
    () => OnboardingDataSourceImplementation(sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImplementation(sl()),
  );
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      onboardingRepository: sl(),
      sharedPreferencesService: sl(),
      localDbService: sl(),
      authRepository: sl(),
      smsMiner: sl(),
    ),
  );
}

_initAuth() {
  sl.registerLazySingleton<AuthService>(() => AuthServiceImplementation(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(sl(), sl()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepo: sl()));
}

_initHome() {
  //sl.registerLazySingleton<AuthService>(() => AuthServiceImplementation(sl()));
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImplementation(sl(), sl()),
  // );
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      localDbService: sl(),
      authRepository: sl(),
      smsMiner: sl(),
      onboardingDataSource: sl(),
    ),
  );
}

_initSplash() {
  sl.registerFactory<SplashCubit>(() => SplashCubit(authRepo: sl()));
}

Future<void> _initSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(sl()),
  );
}

Future<void> _initIsarDb() async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [TransactionEntitySchema, CategoryEntitySchema],
    directory: dir.path,
    inspector: true,
  );

  sl.registerSingleton<Isar>(isar);
  sl.registerLazySingleton<LocalDbService>(() => LocalDbService(sl()));
}

_intiSmsMiningService() {
  sl.registerLazySingleton<SmsMinerService>(() => SmsMinerService(sl(), sl()));
}

_initNavNavigation() {
  sl.registerFactory<NavnavidationCubit>(() => NavnavidationCubit());
}
