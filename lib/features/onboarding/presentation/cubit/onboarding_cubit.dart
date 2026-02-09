import 'package:bloc/bloc.dart';
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/helpers/sms_miner_service.dart';
import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';
import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/core/network/local/shared_preferences_service.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:naira_sms_pulse/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _onboardingRepository;
  final SharedPreferencesService _sharedPreferencesService;
  final SmsMinerService _smsMiner;
  final LocalDbService _localDbService;
  final AuthRepository _authRepository;
  OnboardingCubit({
    required OnboardingRepository onboardingRepository,
    required SharedPreferencesService sharedPreferencesService,
    required LocalDbService localDbService,
    required AuthRepository authRepository,
    required SmsMinerService smsMiner,
  }) : _onboardingRepository = onboardingRepository,
       _sharedPreferencesService = sharedPreferencesService,
       _localDbService = localDbService,
       _authRepository = authRepository,
       _smsMiner = smsMiner,

       super(OnboardingState());

  Future<void> loadBanks() async {
    //loading state
    emit(state.copyWith(isLoading: true));

    //
    final result = await _onboardingRepository.getBanks();

    result.match(
      (result) {
        print(result.userMessage);
        emit(state.copyWith(isLoading: false, error: result.errorMessage));
        //emit error
        //
      },
      (result) {
        emit(state.copyWith(isLoading: false, availableBanks: result));
      },
    );
  }

  void toggleBanks(BankModel bank) {
    final updatedBanks = List<BankModel>.from(state.selectedBanks);

    if (updatedBanks.contains(bank)) {
      updatedBanks.remove(bank);
    } else {
      updatedBanks.add(bank);
    }
    emit(state.copyWith(selectedBanks: updatedBanks));
  }

  Future<void> nextPage() async {
    if (state.selectedBanks.isEmpty) {
      // UI should prevent this, but always double-protect
      print('No banks selected');
      return;
    }
    emit(state.copyWith(isLoading: true));
    final uploadBanks = await _onboardingRepository.saveSelectedBanks(
      state.selectedBanks,
    );
    uploadBanks.match(
      (uploadBanks) {
        emit(state.copyWith(isLoading: false, error: uploadBanks.userMessage));
      },
      (uploadBanks) {
        emit(state.copyWith(isLoading: false, pageIndex: 1));
      },
    );
  }

  void grantInitialPermission() async {
    emit(state.copyWith(initialPermission: true));
  }

  Future<void> grantSmsPermission() async {
    // 1. UI State: Loading
    emit(state.copyWith(initialPermission: false, isLoading: true));

    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        throw AppErrors(
          errorMessage: 'User not logged in',
          userMessage: 'User not logged in',
          errorType: ErrorType.authentication,
        );
      }

      final List<BankParsingRule> myBankRules = nigeriaBankRules.where((rule) {
        return state.selectedBanks.any(
          (selectedBank) => selectedBank.id == rule.bankId,
        );
      }).toList();

      if (myBankRules.isEmpty) {
        print("⚠️ No matching rules found. Sync might be empty.");
      }
      // ---------------------------------------------------------
      // 3. THE TESLA SWITCH 🚀
      // ---------------------------------------------------------
      // Old Way: _smsMiner.mineTransactions(...) -> Returned raw list
      // New Way: _smsMiner.syncTransactions(...) -> Returns void (Handles AI + DB + Dedupe internally)

      print("🔄 Starting robust sync pipeline...");
      await _smsMiner.syncAndMineTransactions(
        activeRules: myBankRules,
        userId: currentUser.id,
      );

      // ---------------------------------------------------------
      // 4. UPDATE UI (Single Source of Truth)
      // ---------------------------------------------------------
      // Now that the Service has safely saved everything to Isar,
      // we fetch the clean data from Isar to display it.

      final savedTransactionEntities = await _localDbService.getAllTransactions(
        userId: currentUser.id,
      );

      final uiTransactions = savedTransactionEntities
          .map((e) => e.toModel())
          .toList();

      print(
        "✅ Sync done. DB now has ${savedTransactionEntities.length} total transactions.",
      );

      // 5. Persist Onboarding State
      await _sharedPreferencesService.saveIsOnboarded(currentUser.id);

      // 6. Finish
      emit(
        state.copyWith(
          isLoading: false,
          smsPermission: true,
          transactions:
              uiTransactions, // Convert Entity to Model if needed for UI
        ),
      );
    } catch (e) {
      print("Cubit Error: $e");
      emit(
        state.copyWith(
          isLoading: false,
          smsPermission: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> checkOnboardingStatusAndNavigate({
    required String userId,
  }) async {
    final bool isOnBoarded = _sharedPreferencesService.getIsOnBordedValue(
      userId,
    );

    print("🧐 Checking Onboarding Status. Value found: $isOnBoarded");
    if (isOnBoarded) {
      emit(
        state.copyWith(onBoardingStatus: OnBoardingStatus.onBoardingFinished),
      );
    } else {
      emit(
        state.copyWith(onBoardingStatus: OnBoardingStatus.onBoardingUnfinished),
      );
    }
  }
}
