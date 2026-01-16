import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Singleton instance
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._();
  static SharedPreferences? _preferences;

  // Private constructor to ensure singleton pattern
  SharedPreferencesHelper._() {
    init(); // Initialize preferences when the instance is created
  }

  // Factory constructor to provide access to the singleton instance
  factory SharedPreferencesHelper() {
    return _instance;
  }

  // Initialization method to be called on app load
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Set String value in SharedPreferences
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  // Get String value from SharedPreferences
  String getString(String key, {required String defaultValue}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  // Set Bool value in SharedPreferences
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Get Bool value from SharedPreferences
  bool getBool(String key, {required bool defaultValue}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }
}

// Example of usage:
// In your main.dart or wherever you initialize your app, call SharedPreferencesHelper.init()
// SharedPreferencesHelper.init();

// Then, you can use SharedPreferencesHelper to set and get values like this:
// SharedPreferencesHelper().setString('username', 'JohnDoe');
// String username = SharedPreferencesHelper().getString('username');

// SharedPreferencesHelper().setBool('isLogged', true);
// bool isLogged = SharedPreferencesHelper().getBool('isLogged');
