import '../../repositories/preference.dart';

/// Use case để kiểm tra thông báo có được bật không
class GetNotificationsEnabled {
  final PreferenceRepository _repository;

  GetNotificationsEnabled(this._repository);

  Future<bool> call() async {
    return await _repository.getNotificationsEnabled();
  }
}

