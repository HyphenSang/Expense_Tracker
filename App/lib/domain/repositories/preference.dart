/// Repository interface cho Preferences trong domain layer
abstract class PreferenceRepository {
  /// Kiểm tra thông báo có được bật không
  Future<bool> getNotificationsEnabled();

  /// Bật/tắt thông báo
  Future<void> setNotificationsEnabled(bool enabled);
}

