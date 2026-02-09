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

    // 1. Define the "Floor" (Jan 1st, 00:00:00)
    final now = DateTime.now();
    final int startOfYear = DateTime(now.year, 1, 1).millisecondsSinceEpoch;

    // 2. Get Last Sync (Optimization)
    // If we synced yesterday, we only need to fetch back to yesterday, not Jan 1st.
    final int? storedTimestamp = _prefs.getInt('last_sync_timestamp');
    final int fetchLimitTimestamp =
        (storedTimestamp != null && storedTimestamp > startOfYear)
        ? storedTimestamp
        : startOfYear;

    List<SmsMessage> allMessages = [];
    bool hasMore = true;
    int start = 0; // Pagination Offset
    const int batchSize = 500; // Safe batch size

    print(
      "📅 Fetching messages since: ${DateTime.fromMillisecondsSinceEpoch(fetchLimitTimestamp)}",
    );

    // 3. THE SMART LOOP 🔄
    try {
      while (hasMore) {
        // Fetch a batch (e.g., 0-500, then 500-1000...)
        final batch = await _query.querySms(
          kinds: [SmsQueryKind.inbox],
          start: start,
          count: batchSize,
        );

        if (batch.isEmpty) {
          hasMore = false;
          break;
        }

        // Check the date of the *last* message in this batch
        // (Messages are usually returned newest-first)
        final lastMsgDate = batch.last.date?.millisecondsSinceEpoch ?? 0;

        // Filter this batch: Keep only messages newer than our limit
        final validMessages = batch.where((msg) {
          return (msg.date?.millisecondsSinceEpoch ?? 0) >= fetchLimitTimestamp;
        }).toList();

        allMessages.addAll(validMessages);

        // DECISION TIME:
        if (lastMsgDate < fetchLimitTimestamp) {
          // The batch went back too far (e.g., into last year).
          // We found the "edge" of our data. Stop fetching.
          hasMore = false;
          print("🛑 Reached limit. Stopping fetch.");
        } else {
          // The whole batch was from this year. There might be more.
          // Move the offset to fetch the next page.
          start += batchSize;
          print(
            "➡️ Fetched $batchSize messages... digging deeper (Current total: ${allMessages.length})",
          );
        }
      }

      print("✅ Total Relevant Messages: ${allMessages.length}");

      if (allMessages.isEmpty) return;

      // ... (Continue with your MiningJob logic using `allMessages`) ...

      final job = MiningJob(messages: allMessages, rules: activeRules);


      List<TransactionModel> rawTransactions = await compute(
        _processMessagesInIsolate,
        MiningJobWithType(job: job, lastSyncTime: fetchLimitTimestamp),
      );


      // 1. Filter out duplicates (Signatures)
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

      // =================================================================
      // 🚦 THE NEW "BUS STOP" LOGIC
      // =================================================================

      // 2. SAVE IMMEDIATELY (As Pending / Uncategorized)
      // We mark them as `isAiEnriched: false` by default in your model,
      // or explicitly set it here just to be safe.
      final pendingTransactions = newTransactions
          .map(
            (t) => t.copyWith(
              isAiEnriched: false,
              categoryName: t.transactionType == TransactionType.credit
                  ? 'Taxable Income'
                  : 'Uncategorized',
            ),
          )
          .toList();

      await _localDb.saveMinigResults(pendingTransactions, userId);
      print("📥 Buffered ${pendingTransactions.length} new items to DB.");

      // 3. CHECK THE QUEUE SIZE
      // We count ALL pending items (including ones from yesterday if they exist)
      final allPendingEntities = await _localDb.getPendingTransactions(userId);
      final totalPendingCount = allPendingEntities.length;

      print("🚌 Current Queue Size: $totalPendingCount / 30");

      // 4. DECIDE: SEND OR WAIT?
      if (totalPendingCount >= 5) {
        print("🚀 Queue full! Launching AI Batch Processor...");

        // Convert entities back to models
        final batchToProcess = allPendingEntities
            .map((e) => e.toModel())
            .toList();

        await _enrichWithAiAndSave(batchToProcess, userId);
      } else {
        print("zzz Waiting for more transactions to fill the bus...");
      }

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

    final totalPendingCount = pendingEntities.length;

    print("🚌 Current Queue Size: $totalPendingCount / 30");

    // 4. DECIDE: SEND OR WAIT?
    if (totalPendingCount >= 5) {
      print("🚀 Queue full! Launching AI Batch Processor...");

      // Convert entities back to models
      final batchToProcess = pendingEntities.map((e) => e.toModel()).toList();

      await _enrichWithAiAndSave(batchToProcess, userId);
    } else {
      print("zzz Waiting for more transactions to fill the bus...");
    }



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



  Future<void> _processBatchStream({
    required List<TransactionModel> transactions,
    required List<String> categories,
    required String userId,
    required bool isCredit,
  }) async {
    final List<TransactionModel> finalResults = [];

    // 1. CONFIGURATION FOR STRICT LIMITS
    int batchSize = 30; // Efficient token usage
    int requestsMade = 0; // Counter
    const int maxDailyRequests = 20; // Your RPD limit

    // 2. PROCESS IN BATCHES
    for (var i = 0; i < transactions.length; i += batchSize) {
      // 🛑 SAFETY CHECK: Daily Limit
      if (requestsMade >= maxDailyRequests) {
        print("⚠️ Daily AI Quota (20 requests) reached. Stopping early.");
        print(
          "💡 The remaining transactions will be processed on the next sync.",
        );
        break;
      }

      final end = (i + batchSize < transactions.length)
          ? i + batchSize
          : transactions.length;
      final batch = transactions.sublist(i, end);

      final descriptions = batch.map((t) => t.description).toList();

      try {
        // 🚀 CALL AI
        final aiResults = await GeminiCategorizer.analyzeBatch(
          descriptions,
          categories,
          isIncome: isCredit,
        );

        // Increment Counter immediately after a call attempt
        requestsMade++;

        bool batchFailed = (aiResults == null);

        // Process Results
        for (var j = 0; j < batch.length; j++) {
          var txn = batch[j];

          if (!batchFailed && j < aiResults.length) {
            final result = aiResults[j];
            finalResults.add(
              txn.copyWith(
                categoryName: result.category,
                transactionParty: result.party,
                isAiEnriched: true,
              ),
            );
          } else {
            // Fallback
            finalResults.add(
              txn.copyWith(
                isAiEnriched: false,
                categoryName: isCredit ? 'Taxable Income' : 'Uncategorized',
              ),
            );
          }
        }
      } catch (e) {
        print("AI Error: $e");
        // Even on error, we might have consumed quota, so be careful.
        // For safety, we treat errors as "processed without AI" or retry later.
      }

      // ⏳ SAFETY DELAY: RPM LIMIT
      // Limit is 5 RPM = 1 request every 12 seconds.
      // We wait 15 seconds to be 100% safe.
      if (i + batchSize < transactions.length) {
        print("⏳ Waiting 15s to respect rate limit...");
        await Future.delayed(const Duration(seconds: 15));
      }
    }

    // 3. SAVE PARTIAL RESULTS
    // Even if we stopped early because of the limit, save what we got!
    if (finalResults.isNotEmpty) {
      await _localDb.saveMinigResults(finalResults, userId);
      print(
        "💾 Saved ${finalResults.length} ${isCredit ? 'Income' : 'Expense'} items.",
      );

      if (requestsMade >= maxDailyRequests) {
        // Optional: Trigger a UI notification here telling the user
        // "Sync paused due to daily limit. Resuming tomorrow."
      }
    }
  }
}

class MiningJobWithType {
  final MiningJob job;
  final int lastSyncTime;

  MiningJobWithType({required this.job, required this.lastSyncTime});
}
