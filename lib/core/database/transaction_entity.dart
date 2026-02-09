import 'package:isar/isar.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';

part 'transaction_entity.g.dart';

@collection
class TransactionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String signature;

  @Index()
  late String userId;

  @Index()
  late int bankId;

  late String bankName;

  late double amount;

  @Index()
  late String transactionType;

  @Index()
  late DateTime date;

  late String description;

  late String transactionParty;
  @Index()
  late String categoryName;

  @Index() // 👈 Critical for fast querying later
  bool isAiEnriched = false;

  bool excludeFromAnalytics = false;

  List<SplitEntity>? splits;

  // Helper function
  TransactionModel toModel() {
    return TransactionModel(
      id: (id == 0) ? Isar.autoIncrement : id,
      bankId: bankId,
      bankName: bankName,
      amount: amount,
      transactionType: transactionType == 'debit'
          ? TransactionType.debit
          : TransactionType.credit,
      date: date,
      description: description,
      transactionParty: transactionParty,
      categoryName: categoryName,
      isAiEnriched: isAiEnriched,
      excludeFromAnalytics: excludeFromAnalytics,
      // 🚀 Convert Isar Links to List<SplitModel>
      splits:
          splits
              ?.map(
                (s) => SplitModel(
                  categoryName: s.categoryName ?? 'Uncategorized',
                  amount: s.amount ?? 0.0,
                  description: s.description ?? '',
                ),
              )
              .toList() ??
          [],
    );
  }
}

@embedded
class SplitEntity {
  String? categoryName;
  double? amount;
  String? description;
}
