import 'package:fpdart/fpdart.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

abstract class OnboardingRepository {
  Future<Either<AppErrors, List<BankModel>>> getBanks();
  Future<Either<AppErrors, Unit>> saveSelectedBanks(List<BankModel> savedBanks);
  Future<Either<AppErrors, List<BankModel>>> getSavedBanks();
}
