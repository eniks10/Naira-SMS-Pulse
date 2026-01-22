// // core/services/gemini_categorizer.dart
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class GeminiData {
//   final String category;
//   final String party;

//   GeminiData({required this.category, required this.party});
// }

// class GeminiCategorizer {
//   static Future<List<GeminiData>?> analyzeBatch(
//     List<String> descriptions,
//     List<String> availableCategories,
//   ) async {
//     if (descriptions.isEmpty || availableCategories.isEmpty) {
//       print("⚠️ AI Skipped: No descriptions or No categories available.");
//       return null;
//     }

//     try {
//       final model = GenerativeModel(
//         model: 'gemini-flash-latest',
//         apiKey: dotenv.env['GEMINI_API_KEY']!,
//         generationConfig: GenerationConfig(
//           responseMimeType: 'application/json',
//         ),
//       );

//       final safeInput = jsonEncode(descriptions);

//       final String categoryListString = availableCategories.join(', ');

//       final prompt =
//           '''
//       You are a financial analyst. For each transaction description below, extract two things:
//      1. "category":
//          - IF IT IS AN EXPENSE (Spending): Choose the best match from: [$categoryListString].
//          - IF IT IS INCOME (Money Coming In):
//             - categorize as "Taxable Income" if it looks like Salary, Wages, Stipend, or Business Payout.
//             - categorize as "Non-Taxable Income" if it looks like a Gift, Loan, Refund, Transfer from Self, or Reversal.
//       2. "party": The name of the merchant, person, or service involved.
//          - If it's a transfer, extract the person's name.
//          - If it's airtime, put the phone number or network.
//          - If unknown, put "Unknown".

//       Input List:
//       $safeInput

//      Return ONLY a JSON Array. Example:
//       [{"category": "${availableCategories.first}", "party": "Sample"}]
//       ''';

//       final content = [Content.text(prompt)];
//       final response = await model.generateContent(content);

//       final responseText = response.text ?? '[]';
//       final cleanJson = responseText
//           .replaceAll('```json', '')
//           .replaceAll('```', '')
//           .trim();

//       // Parse the JSON list
//       List<dynamic> jsonList = jsonDecode(cleanJson);

//       return jsonList.map((item) {
//         return GeminiData(
//           category: item['category'] ?? 'Uncategorized',
//           party: item['party'] ?? 'Unknown',
//         );
//       }).toList();
//     } catch (e) {
//       print("🤖 AI Error: $e");
//       // Fallback: Return dummies if AI fails
//       // return List.filled(
//       //   descriptions.length,
//       //   GeminiData(category: 'Uncategorized', party: 'Unknown'),
//       // );
//       return null; // 👈 Return NULL to signal catastrophic failure
//     }
//   }
// }
// core/services/gemini_categorizer.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiData {
  final String category;
  final String party;

  GeminiData({required this.category, required this.party});
}

class GeminiCategorizer {
  // 🔥 NEW: Add a parameter to distinguish expense vs income processing
  static Future<List<GeminiData>?> analyzeBatch(
    List<String> descriptions,
    List<String> availableCategories, {
    // bool isExpense = true, // 👈 NEW PARAMETER
    required bool isIncome, // 👈 1. Add this argu
  }) async {
    if (descriptions.isEmpty || availableCategories.isEmpty) {
      print("⚠️ AI Skipped: No descriptions or No categories available.");
      return null;
    }

    try {
      final model = GenerativeModel(
        // model: 'gemini-2.0-flash-exp',
        model: 'gemini-flash-latest',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final safeInput = jsonEncode(descriptions);
      final String categoryListString = availableCategories.join(', ');
      String prompt;

      if (isIncome) {
        // --- PROMPT FOR CREDITS (Tax Focused) ---
        prompt =
            '''
          You are a Tax Compliance Analyst. Classify these INCOME transactions.
          
          For each description, extract:
          1. "category": EXACTLY match one from: [$categoryListString].
             - Pick "Taxable Income" for: Salary, Wages, Stipend, Business Payout, Earnings.
             - Pick "Non-Taxable Income" for: Gift, Loan, Refund, Transfer from Self, Reversal.
          2. "party": The sender's name.
          
          Input: $safeInput
          Return JSON Array. Example: [{"category": "Taxable Income", "party": "Work"}]
        ''';
      } else {
        // --- PROMPT FOR DEBITS (Expense Focused) ---
        // This is the "Old" simple prompt that worked well for you before!
        prompt =
            '''
          You are a Budget Analyst. Classify these EXPENSE transactions.
          
          For each description, extract:
          1. "category": Choose the BEST match from: [$categoryListString].
             - Use context clues. e.g., "KFC" -> "Food", "Uber" -> "Transport".
             - Only use "Uncategorized" if it is completely vague.
          2. "party": The merchant or receiver name.
          
          Input: $safeInput
          Return JSON Array. Example: [{"category": "Food & Groceries", "party": "KFC"}]
        ''';
      }

      //   // 🚀 BUILD CONTEXT-AWARE PROMPT
      //       final String categoryInstructions = isExpense
      //           ? '''
      //       These are EXPENSE transactions (money going OUT).
      //       For each transaction, choose the BEST matching category from this list: [$categoryListString].

      //       Examples:
      //       - "Transfer to John Doe" → Shopping (if it's shopping), Food & Groceries (if food-related), or Uncategorized if unclear
      //       - "MTN 500 airtime" → Data and Airtime
      //       - "Netflix subscription" → Subscriptions
      //       - "Uber ride" → Transport
      //       - "Shoprite purchase" → Food & Groceries
      //       '''
      //           : '''
      //       These are INCOME transactions (money coming IN).
      //       Categorize each transaction as either:
      //       - "Taxable Income" if it looks like: Salary, Wages, Stipend, Freelance Payment, Business Payout, Commission, Bonus
      //       - "Non-Taxable Income" if it looks like: Gift, Loan Receipt, Refund, Transfer from Self/Family, Reversal, Reimbursement

      //       Available categories: [$categoryListString]
      //       ''';

      //       final prompt =
      //           '''
      // You are a financial transaction categorization expert.

      // $categoryInstructions

      // For each transaction description below, extract TWO things:

      // 1. "category": The best matching category from the available list
      // 2. "party": The merchant, person, or service name
      //    - For transfers: extract the person's name (e.g., "John Doe")
      //    - For airtime/data: put the network or phone number (e.g., "MTN", "08012345678")
      //    - For merchants: put the business name (e.g., "Shoprite", "Uber")
      //    - If unknown: put "Unknown"

      // Transaction Descriptions:
      // $safeInput

      // Return ONLY a valid JSON array with this exact structure:
      // [{"category": "CategoryName", "party": "PartyName"}]

      // IMPORTANT:
      // - Every category MUST be from the available list
      // - Match transactions to the MOST SPECIFIC category possible
      // - Do NOT make up categories
      // ${isExpense ? '- If truly unsure, use "Uncategorized"' : ''}
      //       ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final responseText = response.text ?? '[]';
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse the JSON list
      List<dynamic> jsonList = jsonDecode(cleanJson);

      return jsonList.map((item) {
        return GeminiData(
          category: item['category'] ?? 'Uncategorized',
          party: item['party'] ?? 'Unknown',
        );
      }).toList();
    } catch (e) {
      print("🤖 AI Error: $e");
      return null;
    }
  }
}
