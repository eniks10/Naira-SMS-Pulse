import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/database/transaction_entity.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/activity/presentation/bloc/activity_state.dart';
import 'package:naira_sms_pulse/features/auth/domian/repository/auth_repo.dart';
import 'package:naira_sms_pulse/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';

part 'activity_event.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final LocalDbService _localDbService;
  final AuthRepository _authRepository;
  final OnboardingDataSource _onboardingDataSource;

  ActivityBloc({
    required LocalDbService localDbService,
    required AuthRepository authRepository,
    required OnboardingDataSource onboardingDataSource,
  }) : _localDbService = localDbService,
       _authRepository = authRepository,
       _onboardingDataSource = onboardingDataSource,
       super(ActivityState()) {
    on<LoadTransactions>(_loadTransactions);
    on<SetDateFilterEvent>(_setDateFilterEvent);
    on<ChangeCategoryEvent>(_changeCategoryEvent);
    on<AddNewCategoryEvent>(_addNewCategoryEvent);
    on<UpdateTransactionPartyEvent>(_updateTransactionPartyEvent);
  }

  FutureOr<void> _loadTransactions(
    LoadTransactions event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      final transactionsEntities = await _localDbService.getAllTransactions(
        userId: user.id,
      );

      final transactions = transactionsEntities
          .map((entity) => entity.toModel())
          .toList();

      transactions.sort((a, b) => b.date.compareTo(a.date));

      final categoryMap = await _localDbService.getCategoryIconMap();
      final myBanks = await _onboardingDataSource.getSavedBanks();
      final categoryList = await _localDbService.getCategoryNames();

      emit(
        state.copyWith(
          isLoading: false,
          transactions: transactions,
          categoryIcons: categoryMap,
          myBanks: myBanks,
          myCategories: categoryList,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  FutureOr<void> _setDateFilterEvent(
    SetDateFilterEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      // 1. SNAPSHOT CURRENT FILTERS (Preserve what is already selected)
      DateTimeRange? targetDateRange = state.dateTimeRange;
      List<String>? targetCategories = state.categoryFilters;
      BankModel? targetBank = state.selectedbank;
      int? targetBankIndex = state.selectedBankIndex;

      // 2. UPDATE ONLY WHAT CHANGED
      // We overwrite the specific filter based on the event index
      if (event.index == 0) {
        targetDateRange = event.timeRange;
      } else if (event.index == 1) {
        targetCategories = event.selectedCategory;
      } else if (event.index == 2) {
        targetBank = event.selectedBank;
        targetBankIndex = event.selectedbankIndex;
      }

      // 3. CALL THE UNIFIED QUERY
      // Pass ALL filters (Old + New) to the database
      final transactionEntity = await _localDbService.getFilteredTransactions(
        userId: user.id,
        dateRange: targetDateRange,
        categories: targetCategories,
        bankId: targetBank?.id,
      );

      final transactions = transactionEntity
          .map((entity) => entity.toModel())
          .toList();

      // 4. EMIT STATE WITH EVERYTHING UPDATED
      emit(
        state.copyWith(
          isLoading: false,
          transactions: transactions,
          // Update the state with the NEW combined values
          dateTimeRange: targetDateRange,
          categoryFilters: targetCategories,
          selectedbank: targetBank,
          selectedBankIndex: targetBankIndex,
        ),
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(isLoading: false));
    }
  }

  FutureOr<void> _changeCategoryEvent(
    ChangeCategoryEvent event,
    Emitter<ActivityState> emit,
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

  FutureOr<void> _addNewCategoryEvent(
    AddNewCategoryEvent event,
    Emitter<ActivityState> emit,
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
          myCategories: newCategoryNames,
        ),
      );
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  FutureOr<void> _updateTransactionPartyEvent(
    UpdateTransactionPartyEvent event,
    Emitter<ActivityState> emit,
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
