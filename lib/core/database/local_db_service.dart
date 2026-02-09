import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:naira_sms_pulse/core/database/category_entity.dart';
import 'package:naira_sms_pulse/core/database/transaction_entity.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/core/utils/icon_serializer.dart';

class LocalDbService {
  // 1. Hold the DB instance directly (No Future needed here)
  final Isar isar;

  // 2. Constructor requires the open DB
  LocalDbService(this.isar);

  // 💾 SAVE BATCH
  Future<void> saveMinigResults(
    List<TransactionModel> models,
    String userId,
  ) async {
    // 3. No need to 'await db' anymore, just use 'isar'
    final entities = models.map((m) {
      return TransactionEntity()
        ..signature = m.transactionHash
        ..bankId = m.bankId
        ..userId = userId
        ..bankName = m.bankName
        ..amount = m.amount
        ..transactionType = m.transactionType.name
        ..categoryName = m.categoryName
        ..transactionParty = m.transactionParty
        ..date = m.date
        ..description = m.description
        ..isAiEnriched = m.isAiEnriched
        ..splits = m.splits
            .map(
              (s) => SplitEntity()
                ..categoryName = s.categoryName
                ..amount = s.amount
                ..description = s.description,
            )
            .toList();
    }).toList();

    await isar.writeTxn(() async {
      // .putAll() combined with the @Index(replace: true) handles deduplication automatically!
      await isar.transactionEntitys.putAll(entities);
    });

    print("💾 Saved ${entities.length} transactions to Isar DB!");
  }

  // 🔍 READ
  Future<List<TransactionEntity>> getAllTransactions({
    required String userId,
  }) async {
    //return await isar.transactionEntitys.where().findAll();
    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId) // 👈 MAGIC FILTER
        .findAll();
  }

  // 🔍 FAST LOOKUP: Get all existing hashes
  Future<Set<String>> getAllSignatures(String userId) async {
    // 1. Query only the 'signature' column
    final List<String> signatures = await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId) // Only checking this user's data
        .signatureProperty() // <--- MAGIC: Selects ONLY this one field
        .findAll();

    // 2. Convert to a Set
    // Why? Searching a List is O(N) (slow). Searching a Set is O(1) (instant).
    return signatures.toSet();
  }

  // 🗑️ CLEAR
  Future<void> clearAllTransactions({required String userId}) async {
    // await isar.writeTxn(() async {
    //   await isar.transactionEntitys.clear();
    // });
    await isar.writeTxn(() async {
      await isar.transactionEntitys.filter().userIdEqualTo(userId).deleteAll();
    });
    print("🗑️ Database cleared!");
  }

  Future<List<TransactionEntity>> getPendingTransactions(String userId) async {
    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId)
        .isAiEnrichedEqualTo(false) // 👈 Find the failures
        .findAll();
  }

  Future<void> updateTransactionVisibility({
    required int id,
    required bool exclude,
  }) async {
    await isar.writeTxn(() async {
      // 1. Find the specific transaction by its Isar ID
      final transaction = await isar.transactionEntitys.get(id);

      if (transaction != null) {
        // 2. Modify ONLY the exclusion flag
        transaction.excludeFromAnalytics = exclude;

        // 3. Save it back (Isar is smart; it updates the existing one, doesn't create a new one)
        await isar.transactionEntitys.put(transaction);
      }
    });
  }

  Future<List<TransactionEntity>> getUserBanks(String userId) async {
    // We filter by User, then ask Isar to only give us UNIQUE bankIds
    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc() // Optional: Get the bank used most recently first
        .distinctByBankId() // 👈 THE MAGIC: Reduces duplicates to 1 per bank
        .findAll();
  }

  // 📄 2. GET TRANSACTIONS FOR SPECIFIC BANK
  Future<List<TransactionEntity>> getTransactionsByBank(
    String userId,
    int bankId,
  ) async {
    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId)
        .and() // Combine logic
        .bankIdEqualTo(bankId) // 👈 Filter by the specific bank
        .sortByDateDesc() // Newest first
        .findAll();
  }

  // features/core/database/local_db_service.dart

  // 📝 UPDATE CATEGORY
  Future<void> updateCategory({
    required int id,
    required String newCategory,
  }) async {
    await isar.writeTxn(() async {
      final transaction = await isar.transactionEntitys.get(id);
      if (transaction != null) {
        transaction.categoryName = newCategory;
        // If it was "Uncategorized", maybe mark it as enriched now?
        if (newCategory != 'Uncategorized') {
          transaction.isAiEnriched = true;
        }
        await isar.transactionEntitys.put(transaction);
      }
    });
  }

  //Update Transaction Party
  Future<void> updateTransactionParty({
    required int id,
    required String newName,
  }) async {
    await isar.writeTxn(() async {
      final transaction = await isar.transactionEntitys.get(id);
      if (transaction != null) {
        transaction.transactionParty = newName;
        // If it was "Uncategorized", maybe mark it as enriched now?
        if (newName != 'Unknown' || newName != 'Unresolved') {
          transaction.isAiEnriched = true;
        }
        await isar.transactionEntitys.put(transaction);
      }
    });
  }

  // ✂️ UPDATE SPLITS
  Future<void> updateTransactionSplits({
    required int id,
    required List<SplitModel> splits,
  }) async {
    await isar.writeTxn(() async {
      final transaction = await isar.transactionEntitys.get(id);

      if (transaction != null) {
        // Convert Models back to Entities
        transaction.splits = splits
            .map(
              (s) => SplitEntity()
                ..categoryName = s.categoryName
                ..amount = s.amount
                ..description = s.description,
            )
            .toList();

        await isar.transactionEntitys.put(transaction);
      }
    });
  }

  
  Future<void> seedDefaultCategories() async {
    // 1. REMOVE THIS LINE 👇
    // final count = await isar.categoryEntitys.count();
    // if (count > 0) return;

    // 2. Define your defaults
    final Map<String, IconData> defaults = {
      'Food & Groceries': Icons.fastfood_rounded,
      'Transport': Icons.directions_car_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Bills & Utilities': Icons.receipt_long_rounded,
      'Data and Airtime': Icons.phone,
      'Subscriptions': Icons.subscriptions_rounded,
      'Pos Withdrawals & Payments': Icons.point_of_sale_rounded,
      'Health': Icons.local_hospital_rounded,
      'Tithe & Offering': Icons.church_rounded,
      'Giving': Icons.card_giftcard_rounded,
      'Uncategorized': Icons.help_outline_rounded,
      'Taxable Income': Icons.account_balance_rounded,
      'Non-Taxable Income': Icons.savings_rounded,
    };

    // 3. "Upsert" Logic (Update or Insert)
    await isar.writeTxn(() async {
      for (var entry in defaults.entries) {
        // Check if this SPECIFIC category exists by name
        final existing = await isar.categoryEntitys
            .filter()
            .nameEqualTo(entry.key)
            .findFirst();

        if (existing == null) {
          // Only add if it's missing
          final newCat = CategoryEntity()
            ..name = entry.key
            ..iconData = IconSerializer.serialize(
              entry.key == 'Uncategorized'
                  ? Icons.help_outline_rounded
                  : entry.value,
            );

          await isar.categoryEntitys.put(newCat);
        }
      }
    });

    print("✅ Smart Seeding Complete (Missing defaults added)");
  }

  // 2. GET NAMES (For Gemini Prompt)
  Future<List<String>> getCategoryNames() async {
    final categories = await isar.categoryEntitys.where().findAll();
    // Exclude 'Uncategorized' from the prompt list to force AI to think
    return categories
        .map((e) => e.name)
        //.where((name) => name != 'Uncategorized')
        .toList();
  }

  // 3. GET FULL MAP (For UI Icons)
  Future<Map<String, IconData>> getCategoryIconMap() async {
    final categories = await isar.categoryEntitys.where().findAll();
    return {
      for (var c in categories) c.name: IconSerializer.deserialize(c.iconData),
    };
  }

  // 4. ADD NEW CATEGORY (User Action)
  Future<void> addCategory(String name, String iconJson) async {
    final newCat = CategoryEntity()
      ..name = name
      ..iconData = iconJson;

    await isar.writeTxn(() async {
      await isar.categoryEntitys.put(newCat);
    });
  }

  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required String userId,
    required DateTimeRange dateTimeRange,
  }) async {
    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId)
        .and()
        .dateBetween(
          dateTimeRange.start,
          dateTimeRange.end,
        ) // 👈 The Magic Filter
        .sortByDateDesc()
        .findAll();
  }

  Future<List<TransactionEntity>> getTransactionsByCategories({
    required String userId,
    required List<String> categories,
  }) async {
    if (categories.isEmpty) return [];

    return await isar.transactionEntitys
        .filter()
        .userIdEqualTo(userId)
        .group((q) {
          // 👇 THE FIX: Use .anyOf() to handle the loop cleanly
          return q.anyOf(
            categories,
            (q, String category) => q.categoryNameEqualTo(category),
          );
        })
        .sortByDateDesc()
        .findAll();
  }

  // 🔍 UNIFIED FILTER METHOD
  Future<List<TransactionEntity>> getFilteredTransactions({
    required String userId,
    DateTimeRange? dateRange,
    List<String>? categories,
    int? bankId,
  }) async {
    List<TransactionEntity> results;

    // 1. PRIMARY QUERY (Isar)
    // Date is the most efficient filter, so we ask the DB for that first.
    if (dateRange != null) {
      results = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .dateBetween(dateRange.start, dateRange.end)
          .findAll();
    } else {
      // If no date selected, get everything (or you could limit to last 30 days)
      results = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .findAll();
    }

    // 2. SECONDARY FILTERS (Dart Memory)
    // This effectively chains the filters together
    final finalResults = results.where((t) {
      // A. Check Bank
      if (bankId != null && t.bankId != bankId) {
        return false; // Skip if bank doesn't match
      }

      // B. Check Categories
      if (categories != null && categories.isNotEmpty) {
        if (!categories.contains(t.categoryName)) {
          return false; // Skip if category is not in the list
        }
      }

      return true; // Keep it
    }).toList();

    // 3. Sort Newest First
    finalResults.sort((a, b) => b.date.compareTo(a.date));

    return finalResults;
  }

  //Filter for Insights Page (date and bank)
  Future<List<TransactionEntity>> insightsFilterTransactions({
    required String userId,
    DateTimeRange? dateRange,
    int? bankId,
  }) async {
    List<TransactionEntity> results;

    // 1. PRIMARY QUERY (Isar)
    // Date is the most efficient filter, so we ask the DB for that first.
    if (dateRange != null) {
      results = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .dateBetween(dateRange.start, dateRange.end)
          .findAll();
    } else {
      // If no date selected, get everything (or you could limit to last 30 days)
      results = await isar.transactionEntitys
          .filter()
          .userIdEqualTo(userId)
          .findAll();
    }

    // 2. SECONDARY FILTERS (Dart Memory)
    // This effectively chains the filters together
    final finalResults = results.where((t) {
      // A. Check Bank
      if (bankId != null && t.bankId != bankId) {
        return false; // Skip if bank doesn't match
      }

      return true; // Keep it
    }).toList();

    // 3. Sort Newest First
    finalResults.sort((a, b) => b.date.compareTo(a.date));

    return finalResults;
  }
}
