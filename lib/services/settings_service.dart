import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyDarkMode = 'isDarkMode';
  static const String _keyCelsius = 'isCelsius';
  static const String _key24Hour = 'is24Hour';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<bool> getIsCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCelsius) ?? true;
  }

  Future<void> setIsCelsius(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCelsius, value);
  }

  Future<bool> getIs24Hour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key24Hour) ?? false;
  }

  Future<void> setIs24Hour(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key24Hour, value);
  }

  double convertTemperature(double celsius, bool isCelsius) {
    return isCelsius ? celsius : (celsius * 9 / 5) + 32;
  }

  String getTemperatureUnit(bool isCelsius) {
    return isCelsius ? '°C' : '°F';
  }
}