import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/auth_bridge.dart';
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // 2.5 seconds to draw
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = Dimensions.screenHeight(context);

    final screenWidth = Dimensions.screenWidth(context);

    // 2. Calculate Responsive Logo Size
    // Logic: "Be 40% of the screen width, but never smaller than 150px or larger than 300px."
    final logoWidth = (screenWidth * 0.4).clamp(150, 300);

    // 3. Maintain Aspect Ratio (1.8 : 1)
    // If width is 180, height should be 100. Ratio = 1.8
    final logoHeight = logoWidth / 1.8;
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.pushReplacementNamed(context, AuthBridge.routeName);
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
                      size: Size(logoWidth, logoHeight),
                      painter: AnimatedPulsePainter(_animation.value),
                    );
                  },
                ),
                // Use 5% of height instead of fixed 20px, so it separates nicely on tall phones
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
