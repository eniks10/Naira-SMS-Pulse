part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

final class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullname;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.fullname,
  });
}

final class ContinueWithGoogleEvent extends AuthEvent {}

final class ContinueWithAppleEvent extends AuthEvent {}

final class ShowLoginEvent extends AuthEvent {}

final class ShowSignUpEvent extends AuthEvent {}

final class LogOutEvent extends AuthEvent {}
