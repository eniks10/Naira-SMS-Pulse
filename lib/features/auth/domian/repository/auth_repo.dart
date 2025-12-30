import 'package:fpdart/fpdart.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<AppErrors, User>> signUp({
    required String email,
    required String password,
    required String fullname,
  });

  Future<Either<AppErrors, User>> logIn({
    required String email,
    required String password,
  });

  Future<Either<AppErrors, Unit>> logOut();

  User? get currentUser;

  Future<Either<AppErrors, User>> refreshSession();
}
