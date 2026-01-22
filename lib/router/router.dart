import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/activity/presentation/pages/activity_page.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/auth_bridge.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_up_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/home_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/transaction_details_page.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/onboarding_bridge.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/onboarding_page.dart';
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

    case OnboardingPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => OnboardingPage(),
      );

    case OnboardingBridge.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => OnboardingBridge(),
      );

    case HomePage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => HomePage(),
      );

    case MainLayoutPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => MainLayoutPage(),
      );

    // case TransactionDetailsPage.routeName:
    //   final args = routeSettings.arguments as Map<String, dynamic>;

    //   // var transaction = routeSettings.arguments as TransactionModel;
    //   // var state = routeSettings.arguments as HomeState;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (context) => TransactionDetailsPage(
    //       transaction: args['transaction'],
    //       state: args['state'],
    //     ),
    //   );
    case TransactionDetailsPage.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>;

      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => TransactionDetailsPage(
          // 1. Pass the Transaction Model
          transaction: args['transaction'],

          // 2. Pass the Data Lists
          categoryNames: args['categoryNames'],
          categoryIcons: args['categoryIcons'],

          // 3. Pass the Functions (Callbacks)
          onCategoryChanged: args['onCategoryChanged'],
          onCategoryAdded: args['onCategoryAdded'],
        ),
      );

    case ActivityPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => ActivityPage(),
      );

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Center(child: Text('Default Screen')),
      );
  }
}
