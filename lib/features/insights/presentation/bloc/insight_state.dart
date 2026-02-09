
import 'package:fl_chart/fl_chart.dart'; // Import this!
import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/insights/data/models/category_summary.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

class InsightState {
  final DateTimeRange timeRange;
  final List<TransactionModel> transactions;
  final TransactionType selectedType;

  // ✅ New fields for the Graph
  final List<FlSpot> graphSpots;
  final double maxAmount;
  final bool isDailyView;
  final List<CategorySummary> categorySummary;
  final Map<String, IconData> categoryIcons;
  final List<String> categoryNames;
  final int selectedBankIndex;
  final List<BankModel> myBanks;
  final List<TransactionModel> cachedRawList;

  InsightState({
    DateTimeRange? timeRange,
    this.transactions = const [],
    this.graphSpots = const [],
    this.maxAmount = 0,
    this.isDailyView = true,
    this.categorySummary = const [],
    this.categoryIcons = const {},
    this.categoryNames = const [],
    this.selectedBankIndex = 0,
    this.myBanks = const [],
    this.selectedType = TransactionType.debit,
    this.cachedRawList = const [],
  }) : timeRange =
           timeRange ??
           DateTimeRange(
             // Default to today (start of day to now)
             start: DateTime(
               DateTime.now().year,
               DateTime.now().month,
               DateTime.now().day,
             ),
             end: DateTime.now(),
           );

  InsightState copyWith({
    DateTimeRange? timeRange,
    List<TransactionModel>? transactions,
    List<FlSpot>? graphSpots,
    double? maxAmount,
    bool? isDailyView,
    List<CategorySummary>? categorySummary,
    Map<String, IconData>? categoryIcons,
    List<String>? categoryNames,
    int? selectedBankIndex,
    List<BankModel>? myBanks,
    TransactionType? selectedType,
    List<TransactionModel>? cachedRawList,
  }) {
    return InsightState(
      timeRange: timeRange ?? this.timeRange,
      transactions: transactions ?? this.transactions,
      graphSpots: graphSpots ?? this.graphSpots,
      maxAmount: maxAmount ?? this.maxAmount,
      isDailyView: isDailyView ?? this.isDailyView,
      categorySummary: categorySummary ?? this.categorySummary,
      categoryIcons: categoryIcons ?? this.categoryIcons,
      categoryNames: categoryNames ?? this.categoryNames,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
      myBanks: myBanks ?? this.myBanks,
      selectedType: selectedType ?? this.selectedType,
      cachedRawList: cachedRawList ?? this.cachedRawList,
    );
  }
}
