import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _temperatureKey = 'settings_temperature';
  static const _maxTokensKey = 'settings_max_tokens';
  static const _contextKey = 'settings_context_enabled';

  Future<double> getTemperature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_temperatureKey) ?? 0.7;
  }

  Future<int> getMaxTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxTokensKey) ?? 512;
  }

  Future<bool> getContextEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_contextKey) ?? true;
  }

  Future<void> saveTemperature(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_temperatureKey, value);
  }

  Future<void> saveMaxTokens(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxTokensKey, value);
  }

  Future<void> saveContextEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contextKey, value);
  }
}
