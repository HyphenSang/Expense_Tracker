import '../repositories/notification.dart';

/// Use case để lấy danh sách ID thông báo đã đọc
class GetReadNotificationIds {
  final NotificationRepository _repository;

  GetReadNotificationIds(this._repository);

  Future<Set<String>> call() async {
    return await _repository.getReadNotificationIds();
  }
}

/// Use case để lưu danh sách ID thông báo đã đọc
class SaveReadNotificationIds {
  final NotificationRepository _repository;

  SaveReadNotificationIds(this._repository);

  Future<void> call(Set<String> ids) async {
    await _repository.saveReadNotificationIds(ids);
  }
}

/// Use case để đánh dấu một thông báo đã đọc
class MarkNotificationAsRead {
  final NotificationRepository _repository;

  MarkNotificationAsRead(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }
}

/// Use case để đánh dấu tất cả thông báo đã đọc
class MarkAllNotificationsAsRead {
  final NotificationRepository _repository;

  MarkAllNotificationsAsRead(this._repository);

  Future<void> call(List<String> notificationIds) async {
    await _repository.markAllAsRead(notificationIds);
  }
}

