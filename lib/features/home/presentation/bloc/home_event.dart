part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class LoadDashBoardEvent extends HomeEvent {}

final class RefreshEvent extends HomeEvent {}

final class ToggleTransactionVisibilityEvent extends HomeEvent {
  final TransactionModel transaction;
  ToggleTransactionVisibilityEvent({required this.transaction});
}

class BankChangedEvent extends HomeEvent {
  final int index;

  BankChangedEvent({required this.index});
}

class ChangeCategoryEvent extends HomeEvent {
  final TransactionModel transaction;
  final String newCategory;
  ChangeCategoryEvent(this.transaction, this.newCategory);
}

class SplitTransactionEvent extends HomeEvent {
  final TransactionModel original;
  final List<Map<String, dynamic>>
  splitData; // [{category: 'Food', amount: 5000}, ...]
  SplitTransactionEvent(this.original, this.splitData);
}

class DateRangeChangedEvent extends HomeEvent {
  final DateTimeRange newRange;
  DateRangeChangedEvent(this.newRange);
}

class RetryAiAnalysisEvent extends HomeEvent {}

class AddNewCategoryEvent extends HomeEvent {
  final String name;
  final String iconJson;
  AddNewCategoryEvent({required this.name, required this.iconJson});
}
