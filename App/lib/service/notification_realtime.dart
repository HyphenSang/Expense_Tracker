import 'dart:async';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/service/notification.dart';
import 'package:expenses/domain/entities/notification.dart' as domain;
import 'package:expenses/domain/features/preference.dart';
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
  static Timer? _debounceTimer;

  /// Stream thông báo real-time
  static Stream<List<domain.NotificationEntity>> get notificationStream => _notificationController.stream;

  /// Stream số lượng thông báo chưa đọc
  static Stream<int> get unreadCountStream => _unreadCountController.stream;

  /// Bắt đầu lắng nghe thay đổi real-time
  static Future<void> startListening() async {
    final user = _currentUser;
    if (user == null) {
      // Nếu không có user, dừng listening nếu đang chạy
      stopListening();
      return;
    }

    // Nếu đã đang lắng nghe, dừng và restart để đảm bảo load lại đúng user
    if (_isListening) {
      stopListening();
    }

    _isListening = true;

    // Clear state cũ trước khi load state mới (tránh conflict giữa các user)
    _readNotificationIds.clear();
    _currentNotifications.clear();

    // Load trạng thái đã đọc từ repository trước (theo user_id mới)
    // Điều này đảm bảo khi đăng nhập lại, trạng thái đã đọc được load lại
    await _loadReadNotificationIds();

    // Load thông báo ban đầu sau khi đã load trạng thái đã đọc
    // _loadNotifications() sẽ tự động load lại read status một lần nữa để đảm bảo
    await _loadNotifications();

    // Lắng nghe thay đổi trong bảng transactions
    _subscription = _client
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false)
        .limit(1)
        .listen((data) {
      // Khi có thay đổi (transaction mới), reload thông báo
      // Đảm bảo áp dụng lại trạng thái đã đọc cho các notification cũ
      // Notification mới sẽ tự động là chưa đọc (đúng hành vi)
      // Sử dụng debounce để tránh reload quá nhiều lần
      _debounceLoadNotifications();
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


  /// Debounce để tránh reload quá nhiều lần khi có nhiều thay đổi liên tiếp
  static void _debounceLoadNotifications() {
    _debounceTimer?.cancel();
    // Giảm debounce time xuống 100ms để cập nhật nhanh hơn
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _loadNotifications();
    });
  }

  /// Dừng lắng nghe và clear state (dùng khi đăng xuất)
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    // Clear state khi dừng listening (khi đăng xuất)
    _readNotificationIds.clear();
    _currentNotifications.clear();
    _notificationController.add([]);
    _unreadCountController.add(0);
  }

  /// Load thông báo và cập nhật stream
  static Future<void> _loadNotifications() async {
    try {
      // Kiểm tra trạng thái bật/tắt thông báo trước
      final getNotificationsEnabled = GetNotificationsEnabled(DI.preferenceRepository);
      final notificationsEnabled = await getNotificationsEnabled();
      
      if (!notificationsEnabled) {
        // Nếu thông báo đã tắt, clear notifications và set unread count = 0
        _currentNotifications = [];
        _notificationController.add([]);
        _unreadCountController.add(0);
        return;
      }
      
      // LUÔN load lại read status trước khi load notifications
      // Đảm bảo có data mới nhất từ SharedPreferences
      await _loadReadNotificationIds();
      
      final notifications = await NotificationService.getNotifications();
      
      // Áp dụng trạng thái đã đọc đã lưu
      // Tạo entities mới với isRead = true nếu đã đọc
      // LƯU Ý: Summary notification được tạo với isRead: true mặc định,
      // nên cần đảm bảo nó luôn được coi là đã đọc
      _currentNotifications = notifications.map((notification) {
        // Nếu notification đã có isRead: true từ NotificationService (như summary),
        // hoặc ID có trong _readNotificationIds, thì coi là đã đọc
        final isRead = notification.isRead || _readNotificationIds.contains(notification.id);
        return domain.NotificationEntity(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          createdAt: notification.createdAt,
          isRead: isRead,
        );
      }).toList();
      
      // Chỉ đếm những notification thực sự chưa đọc
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
    // QUAN TRỌNG: Reload notifications trước để lấy tất cả notifications hiện tại
    // (bao gồm cả những notification mới được tạo từ real-time stream)
    await _loadNotifications();
    
    // Sau khi reload, lấy tất cả notification IDs hiện tại
    // Bao gồm CẢ những notification có isRead: true mặc định (như summary)
    final notificationIds = _currentNotifications.map((n) => n.id).toList();
    
    if (notificationIds.isEmpty) {
      // Không có notification nào để mark
      return;
    }
    
    // Lưu vào repository - mark tất cả notifications hiện tại là đã đọc
    // Điều này đảm bảo rằng khi reload lại, tất cả notifications này sẽ được đánh dấu là đã đọc
    await DI.notificationRepository.markAllAsRead(notificationIds);
    
    // Cập nhật trong memory - đảm bảo tất cả IDs được thêm vào
    _readNotificationIds.addAll(notificationIds);
    
    // Đảm bảo đã lưu vào SharedPreferences (QUAN TRỌNG: phải lưu ngay)
    await DI.notificationRepository.saveReadNotificationIds(_readNotificationIds);
    
    // Cập nhật UI ngay lập tức
    _updateNotifications();
    
    // Đảm bảo unread count = 0 sau khi mark all as read
    _unreadCountController.add(0);
  }

  /// Cập nhật notifications với trạng thái đã đọc
  static void _updateNotifications() {
    // Tạo entities mới với isRead = true nếu đã đọc
    final updatedNotifications = _currentNotifications.map((notification) {
      final isRead = _readNotificationIds.contains(notification.id);
      return domain.NotificationEntity(
        id: notification.id,
        userId: notification.userId,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        createdAt: notification.createdAt,
        isRead: isRead,
      );
    }).toList();
    
    _currentNotifications = updatedNotifications;
    
    // Tính lại unread count - chỉ đếm những notification thực sự chưa đọc
    final unreadCount = _currentNotifications.where((n) => !n.isRead).length;
    
    // Emit cả notifications và unread count
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

