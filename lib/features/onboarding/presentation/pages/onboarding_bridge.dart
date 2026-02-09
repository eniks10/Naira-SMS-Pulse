import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_state.dart'; // Ensure correct import
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/onboarding_page.dart';

class OnboardingBridge extends StatefulWidget {
  static const String routeName = 'onboarding_bridge';

  const OnboardingBridge({super.key});

  @override
  State<OnboardingBridge> createState() => _OnboardingBridgeState();
}

class _OnboardingBridgeState extends State<OnboardingBridge> {
  @override
  void initState() {
    super.initState();
    // 1. Run the check immediately when this page loads
    _checkUserAndOnboarding();
  }

  void _checkUserAndOnboarding() {
    // Get current user from AuthBloc
    final user = context.read<AuthBloc>().state.user;

    print('mai${user}');

    if (user != null) {
      // If logged in, ask Cubit: "Has this person finished onboarding?"
      context.read<OnboardingCubit>().checkOnboardingStatusAndNavigate(
        userId: user.id,
      );
    } else {
      // If not logged in, kick them out immediately
      // Using addPostFrameCallback ensures we don't navigate during a build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, SignInPage.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. Wrap everything in a Listener to watch for SUDDEN Auth changes
    // (e.g., Session Expired, User Logged Out elsewhere)
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.user == null) {
          // 🚨 ZOMBIE FIX: If user suddenly becomes null, kick them out.
          Navigator.pushReplacementNamed(context, SignInPage.routeName);
        }
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          switch (state.onBoardingStatus) {
            case OnBoardingStatus.checking:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case OnBoardingStatus.onBoardingFinished:
              return const MainLayoutPage();
            // return const HomePage();
            case OnBoardingStatus.onBoardingUnfinished:
              return const OnboardingPage();
          }
        },
      ),
    );
  }
}
