import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/notification.dart' as domain;

/// Implementation của NotificationRepository sử dụng SharedPreferences
class NotificationRepositoryImpl implements domain.NotificationRepository {
  static const String _keyReadNotificationIds = 'read_notification_ids';

  @override
  Future<Set<String>> getReadNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIdsJson = prefs.getString(_keyReadNotificationIds);
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
      final readIdsList = ids.toList();
      await prefs.setString(_keyReadNotificationIds, jsonEncode(readIdsList));
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

