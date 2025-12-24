import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/preference.dart' as domain;

/// Implementation của PreferenceRepository sử dụng SharedPreferences
class PreferenceRepositoryImpl implements domain.PreferenceRepository {
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  @override
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true; // Mặc định bật
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }
}

