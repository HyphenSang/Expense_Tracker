/// Repository interface cho Notification trong domain layer
abstract class NotificationRepository {
  /// Lấy danh sách ID thông báo đã đọc
  Future<Set<String>> getReadNotificationIds();

  /// Lưu danh sách ID thông báo đã đọc
  Future<void> saveReadNotificationIds(Set<String> ids);

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId);

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead(List<String> notificationIds);
}

