import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/database/transaction_entity.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

class HomeState {
  final bool isLoading;
  final List<TransactionModel> transactions;
  final double totalSpent;
  final double totalIncome;
  final String errorMessage;
  final int selectedBankIndex;
  final List<TransactionEntity> availableBanks; // 🏦 The Tabs
  final DateTimeRange selectedDateRange;
  final List<BankModel> selectedbanks;
  final Map<String, IconData> categoryIcons;
  final List<String> categoryNames;

  HomeState({
    this.isLoading = false,
    this.transactions = const [],
    this.totalSpent = 0.0,
    this.totalIncome = 0.0,
    this.errorMessage = '',
    this.selectedBankIndex = 0,
    this.availableBanks = const [],
    this.selectedbanks = const [],
    this.categoryIcons = const {},
    this.categoryNames = const [],
    DateTimeRange? selectedDateRange,
  }) : // Default to "This Month" if not provided
       selectedDateRange =
           selectedDateRange ??
           DateTimeRange(
             start: DateTime(DateTime.now().year, DateTime.now().month, 1),
             end: DateTime.now(),
           );

  HomeState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    double? totalSpent,
    double? totalIncome,
    String? errorMessage,
    int? selectedBankIndex,
    List<TransactionEntity>? availableBanks, // 🏦 The Tabs
    DateTimeRange? selectedDateRange,
    List<BankModel>? selectedbanks,
    Map<String, IconData>? categoryIcons,
    List<String>? categoryNames,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      totalSpent: totalSpent ?? this.totalSpent,
      totalIncome: totalIncome ?? this.totalIncome,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
      availableBanks: availableBanks ?? this.availableBanks,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedbanks: selectedbanks ?? this.selectedbanks,
      categoryIcons: categoryIcons ?? this.categoryIcons,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }
}
