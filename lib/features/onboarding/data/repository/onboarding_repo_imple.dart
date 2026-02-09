import 'package:fpdart/src/either.dart';
import 'package:fpdart/src/unit.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/core/network/error/error_handler.dart';
import 'package:naira_sms_pulse/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:naira_sms_pulse/features/onboarding/domain/repository/onboarding_repository.dart';

class OnboardingRepositoryImplementation implements OnboardingRepository {
  final OnboardingDataSource _onboardingDataSource;

  OnboardingRepositoryImplementation(this._onboardingDataSource);

  @override
  Future<Either<AppErrors, List<BankModel>>> getBanks() async {
    try {
      final result = await _onboardingDataSource.getBanks();
      return right(result);
    } catch (e, stackTrace) {
      // <--- Add stackTrace
      // Print the StackTrace so you know EXACTLY where it failed
      print("REPO ERROR: $e");
      print(stackTrace);
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }

  @override
  Future<Either<AppErrors, Unit>> saveSelectedBanks(
    List<BankModel> savedBanks,
  ) async {
    try {
      await _onboardingDataSource.saveSelectedBanks(savedBanks);
      return right(unit);
    } catch (e, stackTrace) {
      print(stackTrace);
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }

  @override
  Future<Either<AppErrors, List<BankModel>>> getSavedBanks() async {
    try {
      final result = await _onboardingDataSource.getSavedBanks();
      return right(result);
    } catch (e, stackTrace) {
      // <--- Add stackTrace
      // Print the StackTrace so you know EXACTLY where it failed
      print("REPO ERROR: $e");
      print(stackTrace);
      return left(ErrorHandler.handleCompleteErrors(e));
    }
  }
}
