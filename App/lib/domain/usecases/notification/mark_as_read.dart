import '../../repositories/notification.dart';

/// Use case để đánh dấu thông báo đã đọc
class MarkNotificationAsRead {
  final NotificationRepository _repository;

  MarkNotificationAsRead(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }
}

