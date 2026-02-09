import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/auth_bridge.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/onboarding_bridge.dart';
import 'package:naira_sms_pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:naira_sms_pulse/features/splash/presentation/widgets/animated_pulse_painter.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash_screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 2.5 seconds to draw
    );

    // Curved animation for smooth "pen stroke" feel
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    );

    _controller.forward().then((_) {
      // Navigate to next screen after animation + delay
      context.read<SplashCubit>().checkAuthStatusAndNavigate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  Widget build(BuildContext context) {
    final screenHeight = Dimensions.screenHeight(context);
    final screenWidth = Dimensions.screenWidth(context);

    // ✅ FIX 1: Use .0 to force doubles, or add .toDouble() at the end
    // Explicitly typing 'double' helps catch errors early.
    final double logoWidth = (screenWidth * 0.4).clamp(150.0, 300.0);

    // 3. Maintain Aspect Ratio (1.8 : 1)
    final double logoHeight = logoWidth / 1.8;

    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is UnAuthenticatedState) {
            Navigator.pushReplacementNamed(context, AuthBridge.routeName);
          } else if (state is AuthenticatedState) {
            Navigator.pushReplacementNamed(context, OnboardingBridge.routeName);
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Animated Logo
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      // ✅ FIX 2: Now logoWidth is definitely a double
                      size: Size(logoWidth, logoHeight),
                      painter: AnimatedPulsePainter(_animation.value),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                // The Text (Fades in slightly later)
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    'PULSE',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
