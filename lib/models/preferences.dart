import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  bool startMaximized;

  Preferences({required this.startMaximized});

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      startMaximized: json['startMaximized'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startMaximized': startMaximized,
    };
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('startMaximized', startMaximized);
  }

  static Future<Preferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    bool startMaximized = prefs.getBool('startMaximized') ?? true; // Default to true
    return Preferences(startMaximized: startMaximized);
  }
}
