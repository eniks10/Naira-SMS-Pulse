import 'package:naira_sms_pulse/core/models/bank_parsing_rule.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Obtain shared preferences.

class SharedPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  Future<void> saveIsOnboarded(String userId) async {
    _prefs.setBool('onboarded_$userId', true);
  }

  bool getIsOnBordedValue(String userId) {
    return _prefs.getBool('onboarded_$userId') ?? false;
  }

  // Optional: Helper to clear only one user if needed
  Future<void> clearUserOnboarding(String userId) async {
    await _prefs.remove('onboarded_$userId');
  }
}
