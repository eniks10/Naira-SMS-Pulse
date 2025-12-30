import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc({required AuthRepository authRepo})
    : _authRepo = authRepo,

      super(AuthState(authpage: AuthPage.logIn)) {
    on<ShowLoginEvent>(_showLoginEvent);
    on<ShowSignUpEvent>(_showSignUpEvent);
    on<LoginEvent>(_loginEvent);
    on<SignUpEvent>(_signUpEvent);
    on<LogOutEvent>(_logOutEvent);
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
        user: null,
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
        user: null,
      ),
    );
  }

  FutureOr<void> _loginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    //loading state
    emit(state.copyWith(isLoading: true, error: null));
    //process api call
    final result = await _authRepo.logIn(
      email: event.email,
      password: event.password,
    );
    result.match(
      (result) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            error: result.userMessage,
          ),
        );
      },
      (result) {
        print('Successfully Logged in');
        emit(state.copyWith(isLoading: false, isSuccess: true, user: result));
      },
    );
  }

  FutureOr<void> _signUpEvent(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    //loading state
    emit(state.copyWith(isLoading: true, error: null));
    //process api call
    final result = await _authRepo.signUp(
      email: event.email,
      password: event.password,
      fullname: event.fullname,
    );
    result.match(
      (result) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            error: result.userMessage,
          ),
        );
      },
      (result) {
        print('Successfully Signed Up');

        emit(state.copyWith(isLoading: false, isSuccess: true, user: result));
      },
    );
  }

  FutureOr<void> _logOutEvent(
    LogOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _authRepo.logOut();
    result.match(
      (result) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            error: result.userMessage,
          ),
        );
      },
      (result) {
        emit(
          AuthState(
            authpage: AuthPage.logIn,
            isLoading: false,
            isSuccess: false,
            user: null, // Default is null, but being explicit helps readability
          ),
        );
      },
    );
  }
}
