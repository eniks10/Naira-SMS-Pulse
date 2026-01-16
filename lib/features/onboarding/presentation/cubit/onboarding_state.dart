// part of 'onboarding_cubit.dart';

// @immutable
// sealed class OnboardingState {}

// final class OnboardingInitial extends OnboardingState {}

// final class BanksSelectedState extends OnboardingState{
//   final List<Map<String, dynamic>> selectedBanks;
//   BanksSelectedState({
//     required this.selectedBanks
//   });
// }

// final class MessagePermissionUnderstoodstate extends OnboardingState{}

import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

enum OnBoardingStatus { checking, onBoardingFinished, onBoardingUnfinished }

class OnboardingState {
  final List<BankModel> selectedBanks;
  final int pageIndex;
  final bool initialPermission;
  final bool smsPermission;
  final List<BankModel> availableBanks;
  final bool isLoading;
  final String? error;
  final OnBoardingStatus onBoardingStatus;
  final List<TransactionModel> transactions;

  OnboardingState({
    this.selectedBanks = const [],
    this.pageIndex = 0,
    this.initialPermission = false,
    this.smsPermission = false,
    this.availableBanks = const [],
    this.isLoading = false,
    this.error,
    this.onBoardingStatus = OnBoardingStatus.checking,
    this.transactions = const [],
  });

  OnboardingState copyWith({
    List<BankModel>? selectedBanks,
    int? pageIndex,
    bool? initialPermission,
    bool? smsPermission,
    List<BankModel>? availableBanks,
    bool? isLoading,
    String? error,
    OnBoardingStatus? onBoardingStatus,
    List<TransactionModel>? transactions,
  }) {
    return OnboardingState(
      selectedBanks: selectedBanks ?? this.selectedBanks,
      pageIndex: pageIndex ?? this.pageIndex,
      initialPermission: initialPermission ?? this.initialPermission,
      smsPermission: smsPermission ?? this.smsPermission,
      availableBanks: availableBanks ?? this.availableBanks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      onBoardingStatus: onBoardingStatus ?? this.onBoardingStatus,
      transactions: transactions ?? this.transactions,
    );
  }
}
