import '../../domain/entities/notification.dart';

/// Data model cho Notification
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    required super.createdAt,
    super.isRead,
  });

  NotificationEntity toEntity() => this;
}

