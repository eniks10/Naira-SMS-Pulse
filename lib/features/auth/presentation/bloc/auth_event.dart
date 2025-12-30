part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class LoginEvent extends AuthEvent {}

final class SignUpEvent extends AuthEvent {}

final class ContinueWithGoogleEvent extends AuthEvent {}

final class ContinueWithAppleEvent extends AuthEvent {}

final class ShowLoginEvent extends AuthEvent {}

final class ShowSignUpEvent extends AuthEvent {}
