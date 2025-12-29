import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenses/core/supabase_flutter.dart';
import '../../domain/repositories/notification.dart' as domain;

/// Implementation của NotificationRepository sử dụng SharedPreferences
/// Lưu trạng thái đã đọc theo user_id để tránh conflict giữa các user
class NotificationRepositoryImpl implements domain.NotificationRepository {
  /// Lấy key dựa trên user_id hiện tại
  String _getKey() {
    final user = SupabaseConfig.client.auth.currentUser;
    final userId = user?.id ?? 'anonymous';
    return 'read_notification_ids_$userId';
  }

  @override
  Future<Set<String>> getReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey();
      final readIdsJson = prefs.getString(key);
      if (readIdsJson != null) {
        final List<dynamic> readIdsList = jsonDecode(readIdsJson);
        return readIdsList.cast<String>().toSet();
      }
      return <String>{};
    } catch (e) {
      return <String>{};
    }
  }

  @override
  Future<void> saveReadNotificationIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey();
      final readIdsList = ids.toList();
      await prefs.setString(key, jsonEncode(readIdsList));
    } catch (e) {
      // Nếu lỗi, bỏ qua
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final readIds = await getReadNotificationIds();
    readIds.add(notificationId);
    await saveReadNotificationIds(readIds);
  }

  @override
  Future<void> markAllAsRead(List<String> notificationIds) async {
    final readIds = await getReadNotificationIds();
    readIds.addAll(notificationIds);
    await saveReadNotificationIds(readIds);
  }
}

