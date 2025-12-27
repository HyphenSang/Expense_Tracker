import 'dart:async';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/service/notification.dart';
import 'package:expenses/domain/entities/notification.dart' as domain;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để lắng nghe thông báo real-time
class NotificationRealtimeService {
  static SupabaseClient get _client => SupabaseConfig.client;
  static User? get _currentUser => _client.auth.currentUser;

  static StreamSubscription<SupabaseStreamEvent>? _subscription;
  static final _notificationController = StreamController<List<domain.NotificationEntity>>.broadcast();
  static final _unreadCountController = StreamController<int>.broadcast();
  static List<domain.NotificationEntity> _currentNotifications = [];
  static Set<String> _readNotificationIds = <String>{};
  static bool _isListening = false;

  /// Stream thông báo real-time
  static Stream<List<domain.NotificationEntity>> get notificationStream => _notificationController.stream;

  /// Stream số lượng thông báo chưa đọc
  static Stream<int> get unreadCountStream => _unreadCountController.stream;

  /// Bắt đầu lắng nghe thay đổi real-time
  static Future<void> startListening() async {
    // Nếu đã đang lắng nghe, không làm gì
    if (_isListening) return;
    
    final user = _currentUser;
    if (user == null) return;

    _isListening = true;

    // Load trạng thái đã đọc từ repository trước
    await _loadReadNotificationIds();

    // Load thông báo ban đầu sau khi đã load trạng thái đã đọc
    await _loadNotifications();

    // Lắng nghe thay đổi trong bảng transactions
    _subscription = _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false)
        .limit(1)
        .listen((data) {
      // Khi có thay đổi, reload thông báo (và áp dụng lại trạng thái đã đọc)
      _loadNotifications();
    });
  }

  /// Load trạng thái đã đọc từ repository
  static Future<void> _loadReadNotificationIds() async {
    try {
      _readNotificationIds = await DI.notificationRepository.getReadNotificationIds();
    } catch (e) {
      // Nếu lỗi, bắt đầu với Set rỗng
      _readNotificationIds = <String>{};
    }
  }


  /// Dừng lắng nghe
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Load thông báo và cập nhật stream
  static Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationService.getNotifications();
      
      // Đảm bảo _readNotificationIds đã được load (nếu chưa)
      if (_readNotificationIds.isEmpty) {
        await _loadReadNotificationIds();
      }
      
      // Áp dụng trạng thái đã đọc đã lưu
      // Tạo entities mới với isRead = true nếu đã đọc
      _currentNotifications = notifications.map((notification) {
        if (_readNotificationIds.contains(notification.id)) {
          return domain.NotificationEntity(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            createdAt: notification.createdAt,
            isRead: true,
          );
        }
        return notification;
      }).toList();
      final unreadCount = _currentNotifications.where((n) => !n.isRead).length;
      
      _notificationController.add(_currentNotifications);
      _unreadCountController.add(unreadCount);
    } catch (e) {
      // Nếu lỗi, thêm empty list
      _currentNotifications = [];
      _notificationController.add([]);
      _unreadCountController.add(0);
    }
  }

  /// Reload notifications và trạng thái đã đọc (dùng khi vào lại màn hình)
  static Future<void> reloadNotifications() async {
    await _loadReadNotificationIds();
    await _loadNotifications();
  }

  /// Đánh dấu một thông báo đã đọc
  static Future<void> markAsRead(String notificationId) async {
    await DI.notificationRepository.markAsRead(notificationId);
    _readNotificationIds.add(notificationId);
    _updateNotifications();
  }

  /// Đánh dấu tất cả thông báo đã đọc
  static Future<void> markAllAsRead() async {
    final notificationIds = _currentNotifications.map((n) => n.id).toList();
    await DI.notificationRepository.markAllAsRead(notificationIds);
    _readNotificationIds.addAll(notificationIds);
    _updateNotifications();
  }

  /// Cập nhật notifications với trạng thái đã đọc
  static void _updateNotifications() {
    // Tạo entities mới với isRead = true nếu đã đọc
    final updatedNotifications = _currentNotifications.map((notification) {
      if (_readNotificationIds.contains(notification.id)) {
        return domain.NotificationEntity(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          createdAt: notification.createdAt,
          isRead: true,
        );
      }
      return notification;
    }).toList();
    
    _currentNotifications = updatedNotifications;
    final unreadCount = _currentNotifications.where((n) => !n.isRead).length;
    _notificationController.add(_currentNotifications);
    _unreadCountController.add(unreadCount);
  }

  /// Dispose resources
  static void dispose() {
    stopListening();
    _notificationController.close();
    _unreadCountController.close();
  }
}

