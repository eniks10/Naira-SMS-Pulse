import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_in_page.dart';
import 'package:naira_sms_pulse/features/auth/presentation/pages/sign_up_page.dart';

class AuthBridge extends StatefulWidget {
  static const String routeName = 'auth_bridge';
  const AuthBridge({super.key});

  @override
  State<AuthBridge> createState() => _AuthBridgeState();
}

class _AuthBridgeState extends State<AuthBridge> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.authpage) {
          case AuthPage.logIn:
            return SignInPage();
          case AuthPage.signUp:
            return SignUpPage();
        }
      },
    );
  }
}
