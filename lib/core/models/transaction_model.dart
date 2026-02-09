enum TransactionType { debit, credit }

class TransactionModel {
  final int id;
  final int bankId;
  final String bankName;
  final double amount;
  final TransactionType transactionType;
  final DateTime date;
  final String description;
  final String transactionParty;
  final String categoryName;
  final bool isAiEnriched;
  final bool excludeFromAnalytics;
  final List<SplitModel> splits;

  TransactionModel({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.transactionType,
    required this.date,
    required this.description,
    this.transactionParty = 'Unknown',
    this.categoryName = 'Uncategorized',
    required this.amount,
    this.isAiEnriched = false, // Default to false
    this.excludeFromAnalytics = false,
    this.splits = const [],
  });

  TransactionModel copyWith({
    int? bankId,
    String? bankName,
    double? amount,
    TransactionType? transactionType,
    DateTime? date,
    String? description,
    String? transactionParty,
    String? categoryName,
    bool? isAiEnriched,
    bool? excludeFromAnalytics,
    List<SplitModel>? splits,
  }) {
    return TransactionModel(
      id: id,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      description: description ?? this.description,
      transactionParty: transactionParty ?? this.transactionParty,
      categoryName: categoryName ?? this.categoryName,
      isAiEnriched: isAiEnriched ?? this.isAiEnriched,
      excludeFromAnalytics: excludeFromAnalytics ?? this.excludeFromAnalytics,
      splits: splits ?? this.splits,
    );
  }

  String get transactionHash {
    // We combine: BANK + AMOUNT + TIME + DESCRIPTION
    // Using millisecondsSinceEpoch ensures even 1-second differences are unique
    final rawString =
        "${bankName}_${amount}_${date.millisecondsSinceEpoch}_${description.trim()}";
    return rawString; // We will index this string in the DB
  }
}

class SplitModel {
  final String categoryName;
  final double amount;
  final String description;

  SplitModel({
    required this.categoryName,
    required this.amount,
    required this.description,
  });
}
