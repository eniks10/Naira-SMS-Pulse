// part of 'auth_bloc.dart';

// @immutable
// sealed class AuthState {}

// final class AuthInitial extends AuthState {}
// final class AuthLoading extends AuthState {}
// final class AuthSucccess extends AuthState {}
// final class AuthFailed extends AuthState {}

enum AuthPage { signUp, logIn }

class AuthState {
  final bool isLoading;
  final bool isSuccess;
  final AuthPage authpage;
  final String? error;

  AuthState({
    this.isSuccess = false,
    required this.authpage,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    AuthPage? authpage,
    String? error,
  }) {
    return AuthState(
      isSuccess: isSuccess ?? this.isSuccess,
      authpage: authpage ?? this.authpage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
