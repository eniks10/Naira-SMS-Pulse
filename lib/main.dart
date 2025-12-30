import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_theme.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_up_page.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:naira_sms_pulse/features/splash/presentation/pages/splash_screen.dart';
import 'package:naira_sms_pulse/router/router.dart';
import 'package:naira_sms_pulse/service_locater.dart';

void main() async {
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashCubit>()),

        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) => generateRoute(settings),
      initialRoute: SplashScreen.routeName,
    );
  }
}
