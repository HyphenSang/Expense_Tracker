import '../../repositories/preference.dart';

/// Use case để bật/tắt thông báo
class SetNotificationsEnabled {
  final PreferenceRepository _repository;

  SetNotificationsEnabled(this._repository);

  Future<void> call(bool enabled) async {
    await _repository.setNotificationsEnabled(enabled);
  }
}

