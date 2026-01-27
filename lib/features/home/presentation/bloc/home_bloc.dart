import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart'; // Needed for DateUtils or just DateTime
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/database/transaction_entity.dart';
import 'package:naira_sms_pulse/core/helpers/sms_miner_service.dart';
import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';
import 'package:naira_sms_pulse/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:naira_sms_pulse/features/onboarding/domain/repository/onboarding_repository.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LocalDbService _localDbService;
  final AuthRepository _authRepository;
  final SmsMinerService _smsMiner;
  final OnboardingDataSource _onboardingDataSource;

  // Prevent multiple syncs running at the same time
  bool _isSyncing = false;

  HomeBloc({
    required LocalDbService localDbService,
    required AuthRepository authRepository,
    required SmsMinerService smsMiner,
    required OnboardingDataSource onboardingDataSource,
  }) : _localDbService = localDbService,
       _authRepository = authRepository,
       _smsMiner = smsMiner,
       _onboardingDataSource = onboardingDataSource,
       super(HomeState()) {
    on<LoadDashBoardEvent>(_loadDashBoardEvent);
    on<RefreshEvent>(_refreshEvent);
    on<ToggleTransactionVisibilityEvent>(_toggleTransactionVisibilityEvent);
    on<BankChangedEvent>(_bankChangedEvent);
    on<ChangeCategoryEvent>(_onChangeCategory);
    //on<SplitTransactionEvent>(_splitTransactionEvent);
    on<RetryAiAnalysisEvent>(_onRetryAiAnalysis);
    on<AddNewCategoryEvent>(_onAddNewCategory);
    on<UpdateTransactionPartyEvent>(_updateTransactionPartyEvent);
  }

  // ===========================================================================
  // 1. INITIAL LOAD (Optimized)
  // ===========================================================================
  FutureOr<void> _loadDashBoardEvent(
    LoadDashBoardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _localDbService.seedDefaultCategories();
    final categoryNames = await _localDbService.getCategoryNames();

    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      // STEP A: Fetch Banks ONCE (Single Point of Truth)
      // We do this here and pass the lists down, so we don't query the DB 3 times.
      final uniqueBanks = await _localDbService.getUserBanks(user.id);
      final selectedBanks = await _onboardingDataSource.getSavedBanks();

      // Emit banks immediately so UI can build the pods
      emit(
        state.copyWith(
          availableBanks: uniqueBanks,
          selectedbanks: selectedBanks,
          categoryNames: categoryNames,
        ),
      );

      // STEP B: Show Cached Data (Fast)
      // Use the lists we just fetched
      await _calculateAndEmitTransactions(
        emit,
        userId: user.id,
        banks: selectedBanks,
        allUserBanks: uniqueBanks,
      );

      // STEP C: Background Sync (Invisible)
      // Pass the same list. No new DB call needed.
      if (!_isSyncing) {
        _isSyncing = true;
        await _performSmartSync(user.id, selectedBanks);
        _isSyncing = false;

        // STEP D: Refresh UI with New Data
        // Re-fetch only the transactions (banks haven't changed)
        final updatedUniqueBanks = await _localDbService.getUserBanks(user.id);
        await _calculateAndEmitTransactions(
          emit,
          userId: user.id,
          banks: selectedBanks,
          allUserBanks: updatedUniqueBanks,
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      _isSyncing = false;
    }
  }

  // ===========================================================================
  // 2. REFRESH (Manual Drag)
  // ===========================================================================
  FutureOr<void> _refreshEvent(
    RefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (_isSyncing) return; // Ignore if already syncing
    _isSyncing = true;

    try {
      final user = _authRepository.currentUser;
      if (user == null) return;

      // We DO need to fetch banks here in case the user changed settings
      final selectedBanks = await _onboardingDataSource.getSavedBanks();

      await _performSmartSync(user.id, selectedBanks);

      // 3. RETRY: Check if any previous transactions failed AI, and try them again
      // We check DB first to avoid starting the process if not needed.
      final pending = await _localDbService.getPendingTransactions(user.id);

      if (pending.isNotEmpty) {
        // Call the service directly (Cleanest way)
        await _smsMiner.retryFailedTransactions(user.id);
      }

      // Update UI
      final uniqueBanks = await _localDbService.getUserBanks(user.id);
      await _calculateAndEmitTransactions(
        emit,
        userId: user.id,
        banks: selectedBanks,
        allUserBanks: uniqueBanks,
      );
    } catch (e) {
      // Handle error quietly
    } finally {
      _isSyncing = false;
    }
  }

  // ===========================================================================
  // 3. SWITCH BANKS
  // ===========================================================================
  FutureOr<void> _bankChangedEvent(
    BankChangedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, selectedBankIndex: event.index));
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        // Reuse existing banks from state if possible, or fetch if empty
        final banks = state.selectedbanks.isNotEmpty
            ? state.selectedbanks
            : await _onboardingDataSource.getSavedBanks();

        await _calculateAndEmitTransactions(
          emit,
          userId: user.id,
          banks: banks,
          allUserBanks: state.availableBanks,
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // ===========================================================================
  // 🛠 HELPER: Sync Logic
  // ===========================================================================
  Future<void> _performSmartSync(
    String userId,
    List<dynamic> selectedBanks,
  ) async {
    // Find rules for the user's selected banks
    final List<BankParsingRule> myBankRules = nigeriaBankRules.where((rule) {
      return selectedBanks.any(
        (selectedBank) => selectedBank.id == rule.bankId,
      );
    }).toList();

    if (myBankRules.isNotEmpty) {
      await _smsMiner.syncAndMineTransactions(
        activeRules: myBankRules,
        userId: userId,
      );
    }
  }

  // ===========================================================================
  // 🛠 HELPER: Fetch Transactions & Calculate Totals
  // ===========================================================================
  Future<void> _calculateAndEmitTransactions(
    Emitter<HomeState> emit, {
    required String userId,
    required List<BankModel> banks,
    required List<TransactionEntity> allUserBanks,
  }) async {
    List<TransactionModel> transactions;

    final iconMap = await _localDbService.getCategoryIconMap();

    // 1. Filter Logic
    if (state.selectedBankIndex == 0) {
      // "All Accounts"
      final entities = await _localDbService.getAllTransactions(userId: userId);
      transactions = entities.map((e) => e.toModel()).toList();
    } else {
      // Specific Bank
      if (banks.isEmpty || state.selectedBankIndex - 1 >= banks.length) {
        transactions = [];
      } else {
        final bankModel = banks[state.selectedBankIndex - 1];
        final entities = await _localDbService.getTransactionsByBank(
          userId,
          bankModel.id,
        );
        transactions = entities.map((e) => e.toModel()).toList();
      }
    }

    // 2. Sort
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // 3. Calculate Totals
    final totals = _calculateSpecificTotals(transactions);

    // 4. Emit
    emit(
      state.copyWith(
        isLoading: false,
        availableBanks: allUserBanks, // Use passed list
        selectedbanks: banks, // Use passed list
        transactions: transactions,
        totalSpent: totals.expense,
        totalIncome: totals.income,
        categoryIcons: iconMap,
      ),
    );
  }

  // ... (Paste your _calculateSpecificTotals, _toggleTransactionVisibilityEvent,
  //      _onChangeCategory, and _splitTransactionEvent here. They are unchanged.)

  ({double expense, double income}) _calculateSpecificTotals(
    List<TransactionModel> transactions,
  ) {
    double expense = 0;
    double income = 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    for (var t in transactions) {
      if (t.excludeFromAnalytics) continue;

      if (t.transactionType == TransactionType.credit) {
        if (t.date.isAfter(startOfMonth) ||
            t.date.isAtSameMomentAs(startOfMonth)) {
          income += t.amount;
        }
      } else if (t.transactionType == TransactionType.debit) {
        if (t.date.isAfter(startOfWeek) ||
            t.date.isAtSameMomentAs(startOfWeek)) {
          expense += t.amount;
        }
      }
    }
    return (expense: expense, income: income);
  }

  FutureOr<void> _toggleTransactionVisibilityEvent(
    ToggleTransactionVisibilityEvent event,
    Emitter<HomeState> emit,
  ) async {
    final updatedList = state.transactions.map((t) {
      if (t.id == event.transaction.id) {
        return t.copyWith(excludeFromAnalytics: !t.excludeFromAnalytics);
      }
      return t;
    }).toList();

    final totals = _calculateSpecificTotals(updatedList);

    emit(
      state.copyWith(
        transactions: updatedList,
        totalSpent: totals.expense,
        totalIncome: totals.income,
      ),
    );

    try {
      await _localDbService.updateTransactionVisibility(
        id: event.transaction.id,
        exclude: !event.transaction.excludeFromAnalytics,
      );
    } catch (e) {
      emit(state);
    }
  }

  FutureOr<void> _onChangeCategory(
    ChangeCategoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    // 1. Keep a reference to the OLD list (Safety Net)
    final previousList = state.transactions;

    // 2. Perform Optimistic Update (UI updates instantly)
    final updatedList = state.transactions.map((t) {
      if (t.id == event.transaction.id) {
        // Update Name AND set isAiEnriched to true (since user manually fixed it)
        return t.copyWith(categoryName: event.newCategory, isAiEnriched: true);
      }
      return t;
    }).toList();

    emit(state.copyWith(transactions: updatedList));

    try {
      // 3. Update Database
      await _localDbService.updateCategory(
        id: event.transaction.id,
        newCategory: event.newCategory,
      );
    } catch (e) {
      print("Failed to update category: $e");

      // 4. REVERT on Failure (Safety Net)
      // If DB fails, put the old list back so UI doesn't lie to the user
      emit(
        state.copyWith(
          transactions: previousList,
          errorMessage: "Failed to save category",
        ),
      );
    }
  }

  // FutureOr<void> _splitTransactionEvent(
  //   SplitTransactionEvent event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   final newSplits = event.splitData.map((data) {
  //     return SplitModel(
  //       categoryName: data['category'] as String,
  //       amount: (data['amount'] as num).toDouble(),
  //       description: data['description'] as String? ?? '',
  //     );
  //   }).toList();

  //   final updatedList = state.transactions.map((t) {
  //     if (t.id == event.original.id) {
  //       return t.copyWith(splits: newSplits);
  //     }
  //     return t;
  //   }).toList();

  //   emit(state.copyWith(transactions: updatedList));

  //   try {
  //     await _localDbService.updateTransactionSplits(
  //       id: event.original.id,
  //       splits: newSplits,
  //     );
  //   } catch (e) {
  //     print("Failed to save splits: $e");
  //   }
  // }

  FutureOr<void> _onRetryAiAnalysis(
    RetryAiAnalysisEvent event,
    Emitter<HomeState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      // A. Run the Retry Logic (AI Enrichment)
      await _smsMiner.retryFailedTransactions(user.id);

      // B. Prepare Data for UI Refresh
      // We reuse the banks currently in the state so we don't query DB unnecessarily
      final selectedBanks = state.selectedbanks.isNotEmpty
          ? state.selectedbanks
          : await _onboardingDataSource.getSavedBanks();

      final availableBanks = state.availableBanks.isNotEmpty
          ? state.availableBanks
          : await _localDbService.getUserBanks(user.id);

      // C. Refresh the UI using the correct method name
      await _calculateAndEmitTransactions(
        emit,
        userId: user.id,
        banks: selectedBanks, // 👈 Pass the list
        allUserBanks: availableBanks, // 👈 Pass the list
      );
    } catch (e) {
      print("Retry failed: $e");
      emit(state.copyWith(errorMessage: 'An Error Occured '));
    }
  }

  // FutureOr<void> _onAddNewCategory(
  //   AddNewCategoryEvent event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   try {
  //     await _localDbService.addCategory(event.name, event.iconJson);

  //     // Refresh the icon map so the UI updates immediately
  //     final newIconMap = await _localDbService.getCategoryIconMap();
  //     emit(state.copyWith(categoryIcons: newIconMap));
  //   } catch (e) {
  //     print("Error adding category: $e");
  //   }
  // }
  FutureOr<void> _onAddNewCategory(
    AddNewCategoryEvent event,
    Emitter<HomeState> emit,
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

  FutureOr<void> _updateTransactionPartyEvent(
    UpdateTransactionPartyEvent event,
    Emitter<HomeState> emit,
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
          errorMessage: "Failed to save transaction party",
        ),
      );
    }
  }
}
