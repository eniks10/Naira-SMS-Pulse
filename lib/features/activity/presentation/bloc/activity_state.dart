import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';


class ActivityState {
  final bool isLoading;
  final List<TransactionModel> transactions;
  final DateTimeRange? dateTimeRange;
  final String? errorMessage;
  final Map<String, IconData> categoryIcons;
  final BankModel? selectedbank;
  final List<BankModel> myBanks;
  final List<String> myCategories;
  final List<String>? categoryFilters;
  final int? selectedBankIndex;

  ActivityState({
    this.isLoading = false,
    this.transactions = const [],
    this.errorMessage,
    this.dateTimeRange,
    this.categoryIcons = const {},
    this.selectedbank,
    this.myBanks = const [],
    this.myCategories = const [],
    this.categoryFilters,
    this.selectedBankIndex,
  });

  ActivityState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    String? errorMessage,
    Object? dateTimeRange = _undefined, // Use Object? with sentinel
    Map<String, IconData>? categoryIcons,
    Object? selectedbank = _undefined, // Use Object? with sentinel
    List<BankModel>? myBanks,
    List<String>? myCategories,
    Object? categoryFilters = _undefined, // Use Object? with sentinel
    Object? selectedBankIndex = _undefined, // Use Object? with sentinel
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      dateTimeRange: dateTimeRange == _undefined
          ? this.dateTimeRange
          : dateTimeRange as DateTimeRange?,
      errorMessage: errorMessage,
      categoryIcons: categoryIcons ?? this.categoryIcons,
      selectedbank: selectedbank == _undefined
          ? this.selectedbank
          : selectedbank as BankModel?,
      myBanks: myBanks ?? this.myBanks,
      myCategories: myCategories ?? this.myCategories,
      categoryFilters: categoryFilters == _undefined
          ? this.categoryFilters
          : categoryFilters as List<String>?,
      selectedBankIndex: selectedBankIndex == _undefined
          ? this.selectedBankIndex
          : selectedBankIndex as int?,
    );
  }
}

// Sentinel value to detect "not provided"
const Object _undefined = Object();
