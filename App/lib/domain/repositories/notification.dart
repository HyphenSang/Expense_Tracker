/// Repository interface cho Notification trong domain layer
abstract class NotificationRepository {
  /// Lấy danh sách thông báo của user
  Future<List<NotificationEntity>> getNotifications(String userId);

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId);

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead(String userId);

  /// Xóa thông báo
  Future<void> deleteNotification(String notificationId);
}

/// Entity đại diện cho một thông báo
class NotificationEntity {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

/// Loại thông báo
enum NotificationType {
  transaction,
  reminder,
  weeklySummary,
  budgetAlert,
}

