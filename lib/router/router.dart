import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/auth_bridge.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_up_page.dart';
import 'package:naira_sms_pulse/features/splash/presentation/pages/splash_screen.dart';
import 'package:naira_sms_pulse/router/navigation_animation.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => SplashScreen(),
      );

    case SignUpPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => SignUpPage(),
      );

    case SignInPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => SignInPage(),
      );

    case AuthBridge.routeName:
      return NavigationAnimation(page: AuthBridge());

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Center(child: Text('Default Screen')),
      );
  }
}
