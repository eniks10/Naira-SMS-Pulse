import 'package:get_it/get_it.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initSplash();
  _initAuth();
}

_initSplash() {
  sl.registerFactory<SplashCubit>(() => SplashCubit());
}

_initAuth() {
  sl.registerFactory<AuthBloc>(() => AuthBloc());
}
