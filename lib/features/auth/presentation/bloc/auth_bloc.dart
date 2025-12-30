import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_state.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState(authpage: AuthPage.logIn)) {
    on<AuthEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ShowLoginEvent>(_showLoginEvent);
    on<ShowSignUpEvent>(_showSignUpEvent);
    on<LoginEvent>(_loginEvent);
    on<SignUpEvent>(_signUpEvent);
  }

  FutureOr<void> _showLoginEvent(
    ShowLoginEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        authpage: AuthPage.logIn,
        isSuccess: false,
        isLoading: false,
        error: null,
      ),
    );
  }

  FutureOr<void> _showSignUpEvent(
    ShowSignUpEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        authpage: AuthPage.signUp,
        isSuccess: false,
        isLoading: false,
        error: null,
      ),
    );
  }

  FutureOr<void> _loginEvent(LoginEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(isLoading: true, error: null));

    //Simulate Api call
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }

  FutureOr<void> _signUpEvent(SignUpEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(isLoading: true, error: null));

    //Simulate Api call
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }
}
