import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:naira_sms_pulse/core/config/theme/app_theme.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/cubit/navnavidation_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:naira_sms_pulse/features/splash/presentation/pages/splash_screen.dart';
import 'package:naira_sms_pulse/router/router.dart';
import 'package:naira_sms_pulse/service_locater.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashCubit>()),

        BlocProvider(create: (_) => sl<AuthBloc>()),

        BlocProvider(create: (_) => sl<OnboardingCubit>()),

        BlocProvider(create: (_) => sl<NavnavidationCubit>()),

        BlocProvider(create: (_) => sl<HomeBloc>()),
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
