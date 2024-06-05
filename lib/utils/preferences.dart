import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    preferences.forEach((key, value) {
      if (value is String) {
        prefs.setString(key, value);
      } else if (value is int) {
        prefs.setInt(key, value);
      } else if (value is bool) {
        prefs.setBool(key, value);
      }
    });
  }

  Future<Map<String, dynamic>> loadPreferences(List<String> keys) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> preferences = {};
    for (var key in keys) {
      final value = prefs.get(key);
      preferences[key] = value;
    }
    return preferences;
  }
}
