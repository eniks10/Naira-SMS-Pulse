import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';

// class UniversalParser {
class UniversalParser {
  static TransactionModel? parse(
    String rawBody,
    BankParsingRule rule,
    DateTime timestamp,
  ) {
    // CRITICAL: Replace newlines with spaces for Regex to work on one line
    final cleanBody = rawBody.replaceAll('\n', ' ').replaceAll('\r', ' ');

    try {
      // 1. Amount
      final amountRegExp = RegExp(rule.amountRegex, caseSensitive: false);
      final amountMatch = amountRegExp.firstMatch(cleanBody);
      if (amountMatch == null) return null;

      String amountStr = amountMatch.group(1) ?? '';
      // Remove non-numeric characters except dots
      amountStr = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
      final double amount = double.tryParse(amountStr) ?? 0.0;

      // 2. Debit/Credit (✅ FIXED LOGIC)
      bool isDebit = false;

      // Logic: If the rule has a specific indicator, use it.
      // Otherwise, use a generic fallback pattern.
      String debitPattern = rule.debitIndicator.isNotEmpty
          ? rule.debitIndicator
          : r'Txn:\s*(DR|DEBIT)|Debit:|DR\s+Amt';

      final debitRegex = RegExp(debitPattern, caseSensitive: false);

      if (debitRegex.hasMatch(cleanBody)) {
        isDebit = true;
      }

      // 3. Description
      String description = "Transaction";
      if (rule.descRegex.isNotEmpty) {
        final descRegExp = RegExp(rule.descRegex, caseSensitive: false);
        final descMatch = descRegExp.firstMatch(cleanBody);
        if (descMatch != null) {
          description = descMatch.group(1)?.trim() ?? description;
        }
      }

      return TransactionModel(
        id: 0,
        bankId: rule.bankId,
        bankName: rule.senderName,
        amount: amount,
        transactionType: isDebit
            ? TransactionType.debit
            : TransactionType.credit,
        date: timestamp,
        description: description,
        categoryName: isDebit
            ? 'Uncategorized'
            : 'Taxable Income', // Default all credits to Taxable until proven otherwise
      );
    } catch (e) {
      return null;
    }
  }
}
