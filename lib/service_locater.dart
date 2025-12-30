import 'package:get_it/get_it.dart';
import 'package:naira_sms_pulse/features/auth/data/datasources/auth_service.dart';
import 'package:naira_sms_pulse/features/auth/data/repository/auth_repo_impli.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initSupabase();
  _initAuth();
  _initSplash();
}

_initSupabase() {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

_initAuth() {
  sl.registerLazySingleton<AuthService>(() => AuthServiceImplementation(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(sl(), sl()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepo: sl()));
}

_initSplash() {
  sl.registerFactory<SplashCubit>(() => SplashCubit(authRepo: sl()));
}
