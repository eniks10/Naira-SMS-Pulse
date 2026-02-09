
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
