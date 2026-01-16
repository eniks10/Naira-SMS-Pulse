import 'package:naira_sms_pulse/core/network/error/app_errors.dart';
import 'package:naira_sms_pulse/core/network/error/error_handler.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OnboardingDataSource {
  Future<List<BankModel>> getBanks();
  Future<void> saveSelectedBanks(List<BankModel> savedBanks);
  Future<List<BankModel>> getSavedBanks();
}

class OnboardingDataSourceImplementation extends OnboardingDataSource {
  final SupabaseClient _supabaseClient;

  OnboardingDataSourceImplementation(this._supabaseClient);
  @override
  Future<List<BankModel>> getBanks() async {
    try {
      final response = await _supabaseClient.from('supported_banks').select();
      print(response);

      if (response.isEmpty) {
        print('Bank List is empty');
        throw AppErrors(
          errorMessage: 'Bank List is empty',
          userMessage:
              'Bank list is empty.There is a server error; Try again later.',
          errorType: ErrorType.server,
        );
      }
      return response.map((e) => BankModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }

  @override
  Future<void> saveSelectedBanks(List<BankModel> savedBanks) async {
    try {
      final User? user = _supabaseClient.auth.currentUser;

      if (user != null) {
        final List<Map<String, dynamic>> banks = savedBanks.map((bank) {
          return {'user_id': user.id, 'bank_id': bank.id};
        }).toList();

        print("📤 Sending to Supabase: $banks");
        await _supabaseClient
            .from('user_selected_banks')
            .upsert(banks, onConflict: 'user_id,bank_id');
      } else {
        throw AppErrors(
          errorMessage: 'User no longer exists',
          userMessage: 'User no longer exists',
          errorType: ErrorType.authentication,
        );
      }
    } catch (e) {
      // 🚨 4. THE INTERROGATION: Print the RAW error
      print("❌ CRITICAL SUPABASE ERROR: $e");

      // If it's a PostgrestException, print specific details
      if (e is PostgrestException) {
        print("Detailed Msg: ${e.message}");
        print("Code: ${e.code}");
        print("Details: ${e.details}");
      }
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }

  @override
  Future<List<BankModel>> getSavedBanks() async {
    try {
      final User? user = _supabaseClient.auth.currentUser;

      if (user != null) {
        print("📥 Fetching selected banks for user: ${user.id}");

        // 1. Query Supabase for the IDs (Same as before)
        final idResponse = await _supabaseClient
            .from('user_selected_banks')
            .select('bank_id')
            .eq('user_id', user.id);

        // 2. Extract IDs
        final List<int> selectedIds = List<Map<String, dynamic>>.from(
          idResponse,
        ).map((data) => data['bank_id'] as int).toList();

        if (selectedIds.isEmpty) {
          return []; // Return empty list immediately if no banks selected
        }

        // 3. ⚡ OPTIMIZATION: Fetch ONLY the matching banks from the server
        // We use the '.in_' filter to say "Where ID is inside this list"
        final bankResponse = await _supabaseClient
            .from('supported_banks')
            .select()
            .inFilter('id', selectedIds); // 👈 This saves data and time!

        print("✅ Found ${bankResponse.length} banks.");

        return (bankResponse as List)
            .map((e) => BankModel.fromJson(e))
            .toList();
      } else {
        throw AppErrors(
          errorMessage: 'User not found',
          userMessage: 'Session expired',
          errorType: ErrorType.authentication,
        );
      }
    } catch (e) {
      print("❌ Error fetching banks: $e");
      throw ErrorHandler.handleCompleteErrors(e);
    }
  }
}
