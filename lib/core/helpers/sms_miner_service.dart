import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:naira_sms_pulse/core/database/local_db_service.dart';
import 'package:naira_sms_pulse/core/helpers/gemini_class.dart';
import 'package:naira_sms_pulse/core/helpers/universal_parser.dart';
import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';
import 'package:naira_sms_pulse/core/models/mining_job.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsMinerService {
  final SmsQuery _query = SmsQuery();
  final SharedPreferences _prefs;
  final LocalDbService _localDb;

  SmsMinerService(this._prefs, this._localDb);

  // ===========================================================================
  // 1. SYNC & MINE (Main Function)
  // ===========================================================================
  Future<void> syncAndMineTransactions({
    required List<BankParsingRule> activeRules,
    required String userId,
  }) async {
    print("🔄 STARTING SYNC...");
    await _localDb.seedDefaultCategories();
    print("✅ Categories guaranteed to exist");

    final int lastSyncTime =
        _prefs.getInt('last_sync_timestamp') ??
        DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch;

    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500,
      );

      if (messages.isEmpty) return;

      final job = MiningJob(messages: messages, rules: activeRules);

      List<TransactionModel> rawTransactions = await compute(
        _processMessagesInIsolate,
        MiningJobWithType(job: job, lastSyncTime: lastSyncTime),
      );

      final existingHashes = await _localDb.getAllSignatures(userId);

      final List<TransactionModel> newTransactions = rawTransactions.where((
        txn,
      ) {
        return !existingHashes.contains(txn.transactionHash);
      }).toList();

      if (newTransactions.isEmpty) {
        print("✅ Sync Complete. No new data.");
        await _updateSyncTimestamp();
        return;
      }

      // 🚀 USE THE HELPER FUNCTION HERE
      print("🤖 Sending ${newTransactions.length} NEW items to AI...");
      await _enrichWithAiAndSave(newTransactions, userId);

      await _updateSyncTimestamp();
    } catch (e) {
      print("Miner Error: $e");
    }
  }

  // ===========================================================================
  // 2. RETRY FAILED TRANSACTIONS (The Function You Asked For)
  // ===========================================================================
  Future<void> retryFailedTransactions(String userId) async {
    print("♻️ RETRY JOB: Looking for transactions that failed AI...");

    await _localDb.seedDefaultCategories();

    // 1. Fetch pending items from DB
    final pendingEntities = await _localDb.getPendingTransactions(userId);

    if (pendingEntities.isEmpty) {
      print("✅ No pending AI transactions found.");
      return;
    }

    print("♻️ Found ${pendingEntities.length} pending items. Retrying AI...");

    // 2. Convert Entity -> Model
    final pendingModels = pendingEntities.map((e) => e.toModel()).toList();

    // 3. Reuse the Helper Function
    // This will run them through Gemini again and update the DB
    await _enrichWithAiAndSave(pendingModels, userId);

    print("✅ Retry complete.");
  }

  // ===========================================================================
  // 🧠 HELPER: AI BATCH PROCESSOR (The Brain)
  // ===========================================================================
  Future<void> _enrichWithAiAndSave(
    List<TransactionModel> transactions,
    String userId,
  ) async {
    // 1. FETCH CATEGORIES
    final allCategories = await _localDb.getCategoryNames();

    if (allCategories.isEmpty) {
      print("❌ CRITICAL ERROR: No categories found even after seeding!");
      print("❌ Saving transactions without AI enrichment...");
      await _localDb.saveMinigResults(transactions, userId);
      return;
    }

    // 2. DEFINE THE TWO POOLS
    final incomeCategories = ['Taxable Income', 'Non-Taxable Income'];

    // Expense categories are everything EXCEPT the income ones
    final expenseCategories = allCategories
        .where((c) => !incomeCategories.contains(c))
        .toList();

    // 🚨 ANOTHER DEFENSIVE CHECK
    if (expenseCategories.isEmpty) {
      print("⚠️ WARNING: No expense categories available!");
      print("Available categories: $allCategories");
    }

    print("📊 Using ${expenseCategories.length} expense categories");
    print("📊 Using ${incomeCategories.length} income categories");

    // 3. SPLIT TRANSACTIONS INTO STREAMS
    final List<TransactionModel> debitTransactions = [];
    final List<TransactionModel> creditTransactions = [];

    for (var txn in transactions) {
      if (txn.transactionType == TransactionType.debit) {
        debitTransactions.add(txn);
      } else {
        creditTransactions.add(txn);
      }
    }

    // 4. PROCESS STREAMS SEPARATELY
    // We await them sequentially to be kind to the API rate limit,
    // but you could perform Future.wait([]) if you have a paid tier.

    if (debitTransactions.isNotEmpty) {
      print("📉 Processing ${debitTransactions.length} Debits...");
      await _processBatchStream(
        transactions: debitTransactions,
        categories: expenseCategories,
        userId: userId,
        isCredit: false,
      );
    }

    if (creditTransactions.isNotEmpty) {
      print("📈 Processing ${creditTransactions.length} Credits...");
      await _processBatchStream(
        transactions: creditTransactions,
        categories: incomeCategories,
        userId: userId,
        isCredit: true,
      );
    }
  }
  // // ===========================================================================
  // // 🧠 HELPER: AI BATCH PROCESSOR (The Brain)
  // // ===========================================================================
  // Future<void> _enrichWithAiAndSave(
  //   List<TransactionModel> transactions,
  //   String userId,
  // ) async {
  //   // 1. FETCH DYNAMIC CATEGORIES
  //   // This gets "Food", "Transport", AND "Books" (if user added it)
  //   final List<String> currentCategories = await _localDb.getCategoryNames();

  //   final List<TransactionModel> finalResults = [];
  //   int batchSize = 30; // 30 is safe for free tier

  //   for (var i = 0; i < transactions.length; i += batchSize) {
  //     final end = (i + batchSize < transactions.length)
  //         ? i + batchSize
  //         : transactions.length;

  //     final batch = transactions.sublist(i, end);

  //     // Extract descriptions for AI
  //     final descriptions = batch.map((t) => t.description).toList();

  //     // 🚀 Call AI
  //     final aiResults = await GeminiCategorizer.analyzeBatch(
  //       descriptions,
  //       currentCategories,
  //     );
  //     bool batchFailed = (aiResults == null);

  //     for (var j = 0; j < batch.length; j++) {
  //       var txn = batch[j];

  //       // If Credit, we force logic (technically "Enriched" because we decided on it)
  //       if (txn.transactionType == TransactionType.credit) {
  //         finalResults.add(
  //           txn.copyWith(isAiEnriched: true, categoryName: 'Uncategorized'),
  //         );
  //         continue;
  //       }

  //       // If AI worked
  //       if (!batchFailed && j < aiResults!.length) {
  //         final result = aiResults[j];
  //         finalResults.add(
  //           txn.copyWith(
  //             categoryName: result.category,
  //             transactionParty: result.party,
  //             isAiEnriched: true, // ✅ Success!
  //           ),
  //         );
  //       } else {
  //         // AI Failed or Network Error
  //         // We keep isAiEnriched = false so 'retryFailedTransactions' picks it up next time
  //         finalResults.add(txn.copyWith(isAiEnriched: false));
  //       }
  //     }

  //     // Small delay to be nice to the API
  //     await Future.delayed(const Duration(milliseconds: 200));
  //   }

  //   // Save to DB (Updates existing records because of matching Hash/Signature)
  //   if (finalResults.isNotEmpty) {
  //     await _localDb.saveMinigResults(finalResults, userId);
  //     print("💾 Updated/Saved ${finalResults.length} transactions.");
  //   }
  // }

  Future<void> _updateSyncTimestamp() async {
    await _prefs.setInt(
      'last_sync_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ... (Keep _processMessagesInIsolate exactly as it was) ...
  static List<TransactionModel> _processMessagesInIsolate(
    MiningJobWithType wrapper,
  ) {
    // ... [Copy your existing isolate code here] ...
    final List<TransactionModel> transactions = [];
    final lastSync = wrapper.lastSyncTime;

    // -------------------------------------------------------
    // 1. CREATE THE CACHE (The Optimization)
    // -------------------------------------------------------
    // This map remembers: "GT-Alert" -> GTBank Rule
    // It also remembers: "MTN-Nigeria" -> Empty Rule (So we don't re-scan junk)
    final Map<String, BankParsingRule> ruleCache = {};

    for (var msg in wrapper.job.messages) {
      // 🚀 OPTIMIZATION 1: Time Filter
      if (msg.date != null && msg.date!.millisecondsSinceEpoch <= lastSync) {
        continue;
      }

      final sender = (msg.address ?? '').trim();
      final body = msg.body ?? '';

      // -------------------------------------------------------
      // 2. CHECK CACHE FIRST (O(1) Lookup)
      // -------------------------------------------------------
      BankParsingRule? matchingRule = ruleCache[sender];

      // -------------------------------------------------------
      // 3. IF MISSING, SCAN LIST (O(N) - Runs only once per sender)
      // -------------------------------------------------------
      if (matchingRule == null) {
        // This is the "Expensive" Regex/Contains check
        matchingRule = wrapper.job.rules.firstWhere(
          (rule) =>
              sender.toLowerCase().contains(rule.senderName.toLowerCase()),
          orElse: () => BankParsingRule.empty(),
        );

        // Save result to cache (Even if it's empty/not found!)
        // So next time "MTN" sends a msg, we know instantly to ignore it.
        ruleCache[sender] = matchingRule;
      }

      // Skip if it's not a bank (Empty Rule)
      if (matchingRule.bankId == -1) continue;

      // Parse
      final txn = UniversalParser.parse(
        body,
        matchingRule,
        msg.date ?? DateTime.now(),
      );

      if (txn != null) {
        transactions.add(txn);
      }
    }
    return transactions;
  }

  // Future<void> _processBatchStream({
  //   required List<TransactionModel> transactions,
  //   required List<String> categories,
  //   required String userId,
  //   required bool isCredit,
  // }) async {
  //   final List<TransactionModel> finalResults = [];
  //   int batchSize = 30;

  //   for (var i = 0; i < transactions.length; i += batchSize) {
  //     final end = (i + batchSize < transactions.length)
  //         ? i + batchSize
  //         : transactions.length;
  //     final batch = transactions.sublist(i, end);

  //     final descriptions = batch.map((t) => t.description).toList();

  //     // 🚀 Call AI with the SPECIFIC category list
  //     final aiResults = await GeminiCategorizer.analyzeBatch(
  //       descriptions,
  //       categories,
  //     );

  //     bool batchFailed = (aiResults == null);

  //     for (var j = 0; j < batch.length; j++) {
  //       var txn = batch[j];

  //       // If AI worked
  //       if (!batchFailed && j < aiResults!.length) {
  //         final result = aiResults[j];
  //         finalResults.add(
  //           txn.copyWith(
  //             categoryName: result.category,
  //             transactionParty: result.party,
  //             isAiEnriched: true,
  //           ),
  //         );
  //       } else {
  //         // Fallback logic on failure
  //         finalResults.add(
  //           txn.copyWith(
  //             isAiEnriched: false,
  //             // If it failed, keep the default logic we set in the Parser
  //             categoryName: isCredit ? 'Taxable Income' : 'Uncategorized',
  //           ),
  //         );
  //       }
  //     }

  //     // Small delay to prevent 429 Errors (Too Many Requests)
  //     await Future.delayed(const Duration(milliseconds: 200));
  //   }

  //   // Save to DB
  //   if (finalResults.isNotEmpty) {
  //     await _localDb.saveMinigResults(finalResults, userId);
  //     print(
  //       "💾 Saved ${finalResults.length} ${isCredit ? 'Income' : 'Expense'} items.",
  //     );
  //   }
  // }
  Future<void> _processBatchStream({
    required List<TransactionModel> transactions,
    required List<String> categories,
    required String userId,
    required bool isCredit,
  }) async {
    final List<TransactionModel> finalResults = [];
    int batchSize = 30;

    for (var i = 0; i < transactions.length; i += batchSize) {
      final end = (i + batchSize < transactions.length)
          ? i + batchSize
          : transactions.length;
      final batch = transactions.sublist(i, end);

      final descriptions = batch.map((t) => t.description).toList();

      // 🚀 CRITICAL FIX: Pass the isExpense flag!
      final aiResults = await GeminiCategorizer.analyzeBatch(
        descriptions,
        categories,
        isExpense: !isCredit, // 👈 Debit = Expense, Credit = Income
      );

      bool batchFailed = (aiResults == null);

      for (var j = 0; j < batch.length; j++) {
        var txn = batch[j];

        // If AI worked
        if (!batchFailed && j < aiResults!.length) {
          final result = aiResults[j];
          finalResults.add(
            txn.copyWith(
              categoryName: result.category,
              transactionParty: result.party,
              isAiEnriched: true,
            ),
          );
        } else {
          // Fallback logic on failure
          finalResults.add(
            txn.copyWith(
              isAiEnriched: false,
              categoryName: isCredit ? 'Taxable Income' : 'Uncategorized',
            ),
          );
        }
      }

      // Small delay to prevent 429 Errors (Too Many Requests)
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Save to DB
    if (finalResults.isNotEmpty) {
      await _localDb.saveMinigResults(finalResults, userId);
      print(
        "💾 Saved ${finalResults.length} ${isCredit ? 'Income' : 'Expense'} items.",
      );
    }
  }
}

class MiningJobWithType {
  final MiningJob job;
  final int lastSyncTime;

  MiningJobWithType({required this.job, required this.lastSyncTime});
}
