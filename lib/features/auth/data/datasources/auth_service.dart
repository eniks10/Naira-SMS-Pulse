import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/core/network/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthService {
  Future<User> signUp({
    required String email,
    required String password,
    required String fullname,
  });
  Future<User> logIn({required String email, required String password});
  Future<void> logOut();
  // Get current user if any
  User? get currentUser;
}

class AuthServiceImplementation extends AuthService {
  final SupabaseClient _supabaseClient;

  AuthServiceImplementation(this._supabaseClient);
  @override
  Future<User> logIn({required String email, required String password}) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw AppErrors.server(
          errorMessage: 'Sign up returned null user',
          userMessage: 'Sign up failed. Please try again.',
        );
      }
      return response.user!;
    } catch (e) {
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String fullname,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'full_name': fullname},
      );
      // Edge case: No error thrown, but no user returned
      if (response.user == null) {
        throw AppErrors.server(
          errorMessage: 'Sign up returned null user',
          userMessage: 'Sign up failed. Please try again.',
        );
      }
      return response.user!;
    } catch (e) {
      // ✅ This handles Network, Timeout, AND Supabase errors
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> logOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }
}
