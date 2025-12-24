import '../../repositories/notification.dart';

/// Use case để đánh dấu tất cả thông báo đã đọc
class MarkAllNotificationsAsRead {
  final NotificationRepository _repository;

  MarkAllNotificationsAsRead(this._repository);

  Future<void> call(List<String> notificationIds) async {
    await _repository.markAllAsRead(notificationIds);
  }
}

