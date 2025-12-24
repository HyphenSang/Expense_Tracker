import '../../entities/notification.dart';

/// Use case để lấy danh sách thông báo
/// 
/// Note: Logic generate notifications từ transactions hiện tại 
/// được xử lý trong NotificationService. Use case này sẽ được 
/// implement đầy đủ khi refactor NotificationService.
class GetNotifications {
  GetNotifications();

  Future<List<NotificationEntity>> call() async {
    // TODO: Refactor NotificationService để sử dụng use case này
    // Tạm thời trả về empty list
    return [];
  }
}

