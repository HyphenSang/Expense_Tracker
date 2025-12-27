/// Entity đại diện cho một thông báo trong domain layer
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
  summary,
  alert,
}

