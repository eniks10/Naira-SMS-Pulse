// import 'dart:async';

// import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:meta/meta.dart';
// import 'package:naira_sms_pulse/core/database/local_db_service.dart';
// import 'package:naira_sms_pulse/core/models/transaction_model.dart';
// import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
// import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_state.dart';

// part 'insight_event.dart';

// class InsightBloc extends Bloc<InsightEvent, InsightState> {
//   final LocalDbService _localDbService;
//   final AuthRepository _authRepository;
//   InsightBloc({
//     required LocalDbService localDbService,
//     required AuthRepository authRepository,
//   }) : _localDbService = localDbService,
//        _authRepository = authRepository,
//        super(InsightState()) {
//     on<SetDateFilterEvent>(_setDateFilterEvent);
//   }

//   FutureOr<void> _setDateFilterEvent(
//     SetDateFilterEvent event,
//     Emitter<InsightState> emit,
//   ) async {
//     final user = _authRepository.currentUser;
//     if (user == null) return;

//     try {
//       final entities = await _localDbService.getTransactionsByDateRange(
//         userId: user.id,
//         dateTimeRange: event.timeRange!,
//       );

//       final transaction = entities.map((entity) => entity.toModel()).toList();

//       final expense = transaction
//           .where((txn) => txn.transactionType == TransactionType.debit)
//           .toList();

//       emit(state.copyWith(timeRange: event.timeRange, transactions: expense));
//     } catch (e) {}
//   }
// }
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // Import for FlSpot
import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/insights/data/models/category_summary.dart';
import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_state.dart';
import 'package:naira_sms_pulse/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

part 'insight_event.dart';

class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final LocalDbService _localDbService;
  final AuthRepository _authRepository;
  final OnboardingDataSource _onboardingDataSource;

  InsightBloc({
    required LocalDbService localDbService,
    required AuthRepository authRepository,
    required OnboardingDataSource onboardingDataSource,
  }) : _localDbService = localDbService,
       _authRepository = authRepository,
       _onboardingDataSource = onboardingDataSource,
       super(InsightState()) {
    // on<SetDateFilterEvent>(_setDateFilterEvent);
    on<ChangeCategoryEvent>(_changeCategoryEvent);
    on<AddNewCategoryEvent>(_addNewCategoryEvent);
    on<UpdateTransactionPartyEvent>(_updateTransactionPartyEvent);
    on<SetFilterEvent>(_setFilterEvent);
    on<LoadTransactions>(_loadTransactions);
    on<SetTransactionTypeEvent>(_setTransactionTypeEvent);
  }

  // FutureOr<void> _loadTransactions(
  //   LoadTransactions event,
  //   Emitter<InsightState> emit,
  // ) async {
  //   // emit(state.copyWith(isLoading: true));

  //   final user = _authRepository.currentUser;
  //   if (user == null) return;

  //   try {

  //     DateTime start = event.timeRange.start;
  //     DateTime end = event.timeRange.end;

  //     // ✅ UNIVERSAL FIX: Always extend end to 23:59:59
  //     end = DateTime(end.year, end.month, end.day, 23, 59, 59);

  //     final adjustedRange = DateTimeRange(start: start, end: end);
  //     // 2. FETCH DATA
  //     final entities = await _localDbService.getTransactionsByDateRange(
  //       userId: user.id,
  //       dateTimeRange: adjustedRange,
  //     );

  //     final allTransactions = entities.map((e) => e.toModel()).toList();
  //     final expenses = allTransactions
  //         .where((txn) => txn.transactionType == TransactionType.debit)
  //         .toList();

  //     // 3. GENERATE GRAPH SPOTS
  //     final chartData = _processGraphData(expenses, adjustedRange);

  //     final categoryMap = await _localDbService.getCategoryIconMap();

  //     final categoryNames = await _localDbService.getCategoryNames();

  //     //Donut
  //     final categories = _calculateCategoryBreakdown(
  //       expenses,
  //       _localDbService,
  //       categoryMap,
  //     );

  //     final myBanks = await _onboardingDataSource.getSavedBanks();
  //     // final categoryList = await _localDbService.getCategoryNames();

  //     emit(
  //       state.copyWith(
  //         // isLoading: false,
  //         transactions: expenses,
  //         categoryIcons: categoryMap,
  //         myBanks: myBanks,
  //         timeRange: adjustedRange,
  //         graphSpots: chartData['spots'] as List<FlSpot>,
  //         maxAmount: chartData['max'] as double,
  //         isDailyView: chartData['isDaily'] as bool,
  //         categorySummary: categories,
  //         categoryNames: categoryNames,
  //         selectedBankIndex: 0,
  //       ),
  //     );
  //   } catch (e) {
  //     print(e);
  //     // emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
  //   }
  // }

  // FutureOr<void> _setFilterEvent(
  //   SetFilterEvent event,
  //   Emitter<InsightState> emit,
  // ) async {
  //   // emit(state.copyWith(isLoading: true));

  //   final user = _authRepository.currentUser;
  //   if (user == null) return;

  //   try {
  //     // 1. SNAPSHOT CURRENT FILTERS (Preserve what is already selected)
  //     DateTimeRange? targetDateRange = state.timeRange;
  //     BankModel? targetBank = state.selectedBankIndex != 0
  //         ? state.myBanks[state.selectedBankIndex - 1]
  //         : null;
  //     int? targetBankIndex = state.selectedBankIndex;

  //     // 2. UPDATE ONLY WHAT CHANGED
  //     // We overwrite the specific filter based on the event index
  //     if (event.index == 0 && event.timeRange != null) {
  //       final rawStart = event.timeRange!.start;
  //       final rawEnd = event.timeRange!.end;

  //       // ✅ UNIVERSAL FIX: Always force the End Date to be 23:59:59
  //       // This ensures "Jan 25 - Jan 26" covers ALL of Jan 26, not just the first second.
  //       final adjustedEnd = DateTime(
  //         rawEnd.year,
  //         rawEnd.month,
  //         rawEnd.day,
  //         23,
  //         59,
  //         59,
  //       );

  //       targetDateRange = DateTimeRange(start: rawStart, end: adjustedEnd);
  //     } else if (event.index == 1) {
  //       targetBank = event.selectedBank;
  //       targetBankIndex = event.selectedbankIndex;
  //     }

  //     // 3. CALL THE UNIFIED QUERY
  //     // Pass ALL filters (Old + New) to the database
  //     final transactionEntity = await _localDbService
  //         .insightsFilterTransactions(
  //           userId: user.id,
  //           dateRange: targetDateRange,
  //           bankId: targetBank?.id,
  //         );

  //     final transactions = transactionEntity
  //         .map((entity) => entity.toModel())
  //         .toList();

  //     final expenses = transactions
  //         .where((txn) => txn.transactionType == TransactionType.debit)
  //         .toList();

  //     // 3. GENERATE GRAPH SPOTS
  //     final chartData = _processGraphData(expenses, targetDateRange);

  //     final categoryMap = await _localDbService.getCategoryIconMap();

  //     final categoryNames = await _localDbService.getCategoryNames();

  //     //Donut
  //     final categories = _calculateCategoryBreakdown(
  //       expenses,
  //       _localDbService,
  //       categoryMap,
  //     );

  //     // 4. EMIT STATE WITH EVERYTHING UPDATED
  //     emit(
  //       state.copyWith(
  //         // isLoading: false,
  //         transactions: expenses,
  //         timeRange: targetDateRange,
  //         selectedBankIndex: targetBankIndex,
  //         graphSpots: chartData['spots'] as List<FlSpot>,
  //         maxAmount: chartData['max'] as double,
  //         isDailyView: chartData['isDaily'] as bool,
  //         categorySummary: categories,
  //         categoryNames: categoryNames,
  //       ),
  //     );
  //   } catch (e) {
  //     print(e);
  //     //emit(state.copyWith(isLoading: false));
  //   }
  // }

  // 2. The Event Handler
  FutureOr<void> _setTransactionTypeEvent(
    SetTransactionTypeEvent event,
    Emitter<InsightState> emit,
  ) async {
    // Just update the type, then run the full data refresh logic
    // We pass the NEW type, but keep existing date/bank filters
    await _refreshData(
      emit,
      timeRange: state.timeRange,
      bankIndex: state.selectedBankIndex,
      transactionType: event.type, // Switch type
    );
  }

  // 3. Update existing events to use the helper
  FutureOr<void> _loadTransactions(
    LoadTransactions event,
    Emitter<InsightState> emit,
  ) async {
    // Logic mostly moves to _refreshData
    await _refreshData(
      emit,
      timeRange: event.timeRange,
      bankIndex: 0,
      transactionType: TransactionType.debit, // Default start
    );
  }

  FutureOr<void> _setFilterEvent(
    SetFilterEvent event,
    Emitter<InsightState> emit,
  ) async {
    DateTimeRange range = state.timeRange;
    int bankIndex = state.selectedBankIndex;

    if (event.index == 0) range = event.timeRange!;
    if (event.index == 1) bankIndex = event.selectedbankIndex!;

    await _refreshData(
      emit,
      timeRange: range,
      bankIndex: bankIndex,
      transactionType: state.selectedType, // Keep current tab
    );
  }

  // 4. THE NEW SHARED HELPER (The Brain)
  Future<void> _refreshData(
    Emitter<InsightState> emit, {
    required DateTimeRange timeRange,
    required int bankIndex,
    required TransactionType transactionType,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      // A. Handle Date Logic (The universal fix we did earlier)
      DateTime start = timeRange.start;
      DateTime end = timeRange.end;
      end = DateTime(end.year, end.month, end.day, 23, 59, 59);
      final adjustedRange = DateTimeRange(start: start, end: end);

      // B. Handle Bank Logic
      BankModel? targetBank;
      if (bankIndex != 0 && state.myBanks.isNotEmpty) {
        targetBank = state.myBanks[bankIndex - 1];
      }

      // C. Fetch Data
      final entities = await _localDbService.insightsFilterTransactions(
        userId: user.id,
        dateRange: adjustedRange,
        bankId: targetBank?.id,
      );

      final allTransactions = entities.map((e) => e.toModel()).toList();

      // D. FILTER BY TAB (Expense vs Income)
      final filteredTransactions = allTransactions
          .where((txn) => txn.transactionType == transactionType)
          .toList();

      // E. Process Visuals
      final chartData = _processGraphData(filteredTransactions, adjustedRange);
      final categoryMap = await _localDbService.getCategoryIconMap();
      final categoryNames = await _localDbService.getCategoryNames();
      final categories = _calculateCategoryBreakdown(
        filteredTransactions,
        _localDbService,
        categoryMap,
      );
      final myBanks = await _onboardingDataSource.getSavedBanks();

      // F. Emit
      emit(
        state.copyWith(
          transactions: filteredTransactions, // Shows filtered list
          timeRange: adjustedRange,
          selectedBankIndex: bankIndex,
          selectedType: transactionType, // ✅ Update the tab state
          categoryIcons: categoryMap,
          myBanks: myBanks,
          graphSpots: chartData['spots'] as List<FlSpot>,
          maxAmount: chartData['max'] as double,
          isDailyView: chartData['isDaily'] as bool,
          categorySummary: categories,
          categoryNames: categoryNames,
        ),
      );
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  FutureOr<void> _updateTransactionPartyEvent(
    UpdateTransactionPartyEvent event,
    Emitter<InsightState> emit,
  ) async {
    // 1. Keep a reference to the OLD list (Safety Net)
    final previousList = state.transactions;

    // 2. Perform Optimistic Update (UI updates instantly)
    final updatedList = state.transactions.map((t) {
      if (t.id == event.transaction.id) {
        // Update Name AND set isAiEnriched to true (since user manually fixed it)
        return t.copyWith(transactionParty: event.name, isAiEnriched: true);
      }
      return t;
    }).toList();

    emit(state.copyWith(transactions: updatedList));

    try {
      // 3. Update Database
      await _localDbService.updateTransactionParty(
        id: event.transaction.id,
        newName: event.name,
      );
    } catch (e) {
      print("Failed to update TransactionParty: $e");

      // 4. REVERT on Failure (Safety Net)
      // If DB fails, put the old list back so UI doesn't lie to the user
      emit(
        state.copyWith(
          transactions: previousList,
          // errorMessage: "Failed to save transaction party",
        ),
      );
    }
  }

  // --- HELPER TO CALCULATE SPOTS ---
  Map<String, dynamic> _processGraphData(
    List<TransactionModel> transactions,
    DateTimeRange range,
  ) {
    // Logic: If duration < 24 hours, show Hourly view. Else show Daily view.
    final bool isDaily = range.duration.inHours <= 24;
    List<FlSpot> spots = [];
    double maxAmount = 0;

    if (isDaily) {
      // --- MODE A: HOURLY (0 - 23) ---
      // 1. Create a map for 24 hours initialized to 0
      Map<int, double> hourlyTotals = {for (var i = 0; i < 24; i++) i: 0};

      // 2. Fill with transaction data
      for (var txn in transactions) {
        hourlyTotals[txn.date.hour] =
            (hourlyTotals[txn.date.hour] ?? 0) + txn.amount;
      }

      // 3. Convert to Spots
      hourlyTotals.forEach((hour, amount) {
        if (amount > maxAmount) maxAmount = amount;
        spots.add(FlSpot(hour.toDouble(), amount));
      });
    } else {
      // --- MODE B: DATE RANGE (Day 0 to Day N) ---
      // 1. Calculate number of days
      int daysDifference =
          range.end.difference(range.start).inDays +
          1; // +1 to include start day

      // 2. Create map for each day index
      Map<int, double> dailyTotals = {
        for (var i = 0; i < daysDifference; i++) i: 0,
      };

      // 3. Fill data
      for (var txn in transactions) {
        // Find which "Day Index" this transaction belongs to (e.g. Day 0, Day 1...)
        // We compare just the dates (ignoring time)
        final txnDate = DateTime(txn.date.year, txn.date.month, txn.date.day);
        final startDate = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );

        final index = txnDate.difference(startDate).inDays;

        if (index >= 0 && index < daysDifference) {
          dailyTotals[index] = (dailyTotals[index] ?? 0) + txn.amount;
        }
      }

      // 4. Convert to Spots
      dailyTotals.forEach((index, amount) {
        if (amount > maxAmount) maxAmount = amount;
        spots.add(FlSpot(index.toDouble(), amount));
      });
    }

    // Sort spots by X to ensure graph draws correctly
    spots.sort((a, b) => a.x.compareTo(b.x));

    return {'spots': spots, 'max': maxAmount, 'isDaily': isDaily};
  }

  FutureOr<void> _changeCategoryEvent(
    ChangeCategoryEvent event,
    Emitter<InsightState> emit,
  ) async {
    // 1. Keep reference to OLD state (Safety Net)
    final previousState = state; // Save the WHOLE state, not just list

    // 2. Create the New List (Optimistic)
    final updatedList = state.transactions.map((t) {
      if (t.id == event.transaction.id) {
        return t.copyWith(categoryName: event.newCategory, isAiEnriched: true);
      }
      return t;
    }).toList();

    // 3. RECALCULATE CHARTS (The Ripple Effect)
    // Since the category changed, the Donut chart needs to update!
    final newCategorySummaries = await _calculateCategoryBreakdown(
      updatedList,
      _localDbService, // You might need this if you fetch icons
      state.categoryIcons,
    );

    // (Optional) If changing category affects the Graph (e.g. colors), recalc that too
    // If your graph is just "Total Amount vs Time", you don't need this step.
    // final newGraphData = _processGraphData(updatedList, state.timeRange);

    // 4. EMIT THE UPDATE (Don't comment this out!)
    emit(
      state.copyWith(
        transactions: updatedList,
        categorySummary: newCategorySummaries, // ✅ Update the Donut Chart
        // graphSpots: newGraphData['spots'], // Only if graph changes
      ),
    );

    try {
      // 5. Update Database
      await _localDbService.updateCategory(
        id: event.transaction.id,
        newCategory: event.newCategory,
      );
    } catch (e) {
      print("Failed to update category: $e");

      // 6. REVERT on Failure
      // Reset to the exact state before the user clicked
      emit(previousState);
    }
  }

  FutureOr<void> _addNewCategoryEvent(
    AddNewCategoryEvent event,
    Emitter<InsightState> emit,
  ) async {
    try {
      // 1. Save to Database
      await _localDbService.addCategory(event.name, event.iconJson);

      // 2. Fetch BOTH updated Lists
      final newIconMap = await _localDbService.getCategoryIconMap();

      // 👇 CHANGE THIS LINE
      final newCategoryNames = await _localDbService.getCategoryNames();

      // 3. Emit BOTH updates to the UI
      emit(
        state.copyWith(
          categoryIcons: newIconMap,
          categoryNames: newCategoryNames,
        ),
      );
    } catch (e) {
      print("Error adding category: $e");
    }
  }
}

// Add this helper method to your InsightBloc class
List<CategorySummary> _calculateCategoryBreakdown(
  List<TransactionModel> transactions,
  LocalDbService localDb,
  Map<String, IconData> iconMap,
) {
  if (transactions.isEmpty) return [];

  // 1. Group by Category Name
  Map<String, double> categoryTotals = {};
  double totalSpent = 0;

  for (var txn in transactions) {
    // You might need to access txn.category.name if category is an object
    final catName = txn.categoryName;
    categoryTotals[catName] = (categoryTotals[catName] ?? 0) + txn.amount;
    totalSpent += txn.amount;
  }

  // 2. Convert to List and Sort (Highest first)
  List<CategorySummary> summaries = [];

  // Define a palette of colors to cycle through
  final List<Color> palette = [
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
    Colors.indigo,
    Colors.deepOrange,
    Colors.lightGreen,
  ];
  int colorIndex = 0;

  categoryTotals.forEach((name, amount) {
    summaries.add(
      CategorySummary(
        name: name,
        totalAmount: amount,
        percentage: totalSpent == 0 ? 0 : amount / totalSpent,
        color: palette[colorIndex % palette.length], // Cycle colors
        icon:
            iconMap[name] ??
            Icons.category, // You can map specific icons here based on name
      ),
    );
    colorIndex++;
  });

  // Sort descending
  summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  return summaries;
}
