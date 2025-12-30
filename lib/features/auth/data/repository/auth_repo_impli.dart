import 'package:fpdart/fpdart.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/core/network/error/error_handler.dart';
import 'package:naira_sms_pulse/features/auth/data/datasources/auth_service.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthService _authService;
  final SupabaseClient _supabaseClient;
  AuthRepositoryImplementation(this._authService, this._supabaseClient);

  @override
  Future<Either<AppErrors, User>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.logIn(email: email, password: password);
      return right(result);
    } catch (e) {
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }

  @override
  Future<Either<AppErrors, Unit>> logOut() async {
    try {
      await _authService.logOut();
      return right(unit);
    } catch (e) {
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }

  @override
  Future<Either<AppErrors, User>> signUp({
    required String email,
    required String password,
    required String fullname,
  }) async {
    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullname: fullname,
      );
      return right(result);
    } catch (e) {
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }

  @override
  User? get currentUser {
    return _authService.currentUser;
  }

  @override
  Future<Either<AppErrors, User>> refreshSession() async {
    try {
      final result = await _supabaseClient.auth.getUser();
      if (result.user == null) {
        throw AppErrors(
          errorMessage: 'User no longer exists',
          userMessage: 'User no longer exists',
          errorType: ErrorType.authentication,
        );
      }
      return right(result.user!);
    } catch (e) {
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }
}
