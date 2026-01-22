part of 'activity_bloc.dart';

sealed class ActivityEvent {}

class LoadTransactions extends ActivityEvent {}

class SetDateFilterEvent extends ActivityEvent {
  final int index;
  final DateTimeRange? timeRange;
  final List<String>? selectedCategory;
  final BankModel? selectedBank;
  final int? selectedbankIndex;
  SetDateFilterEvent({
    required this.index,
    this.timeRange,
    this.selectedCategory,
    this.selectedBank,
    this.selectedbankIndex,
  });
}

class ChangeCategoryEvent extends ActivityEvent {
  final TransactionModel transaction;
  final String newCategory;
  ChangeCategoryEvent(this.transaction, this.newCategory);
}

class AddNewCategoryEvent extends ActivityEvent {
  final String name;
  final String iconJson;
  AddNewCategoryEvent({required this.name, required this.iconJson});
}
