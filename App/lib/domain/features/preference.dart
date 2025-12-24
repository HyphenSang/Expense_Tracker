import '../repositories/preference.dart';

/// Use case để lấy trạng thái bật/tắt thông báo
class GetNotificationsEnabled {
  final PreferenceRepository _repository;

  GetNotificationsEnabled(this._repository);

  Future<bool> call() async {
    return await _repository.getNotificationsEnabled();
  }
}

/// Use case để bật/tắt thông báo
class SetNotificationsEnabled {
  final PreferenceRepository _repository;

  SetNotificationsEnabled(this._repository);

  Future<void> call(bool enabled) async {
    await _repository.setNotificationsEnabled(enabled);
  }
}

