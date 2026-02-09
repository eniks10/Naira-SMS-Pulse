part of 'insight_bloc.dart';

@immutable
sealed class InsightEvent {}


class ChangeCategoryEvent extends InsightEvent {
  final TransactionModel transaction;
  final String newCategory;
  ChangeCategoryEvent(this.transaction, this.newCategory);
}

class AddNewCategoryEvent extends InsightEvent {
  final String name;
  final String iconJson;
  AddNewCategoryEvent({required this.name, required this.iconJson});
}

class UpdateTransactionPartyEvent extends InsightEvent {
  final TransactionModel transaction;
  final String name;

  UpdateTransactionPartyEvent({required this.transaction, required this.name});
}

class SetFilterEvent extends InsightEvent {
  final int index;
  final DateTimeRange? timeRange;
  final BankModel? selectedBank;
  final int? selectedbankIndex;
  SetFilterEvent({
    required this.index,
    this.timeRange,
    this.selectedBank,
    this.selectedbankIndex,
  });
}

class LoadTransactions extends InsightEvent {
  final DateTimeRange timeRange;

  LoadTransactions({required this.timeRange});
}

class SetTransactionTypeEvent extends InsightEvent {
  final TransactionType type;
  SetTransactionTypeEvent(this.type);
}
