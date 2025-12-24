import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/notification_realtime.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/entities/notification.dart' as domain;
import 'package:expenses/domain/usecases/preference/get_notifications_enabled.dart';
import 'package:expenses/domain/usecases/preference/set_notifications_enabled.dart';
import 'package:expenses/domain/usecases/notification/mark_as_read.dart';
import 'package:expenses/domain/usecases/notification/mark_all_as_read.dart';

/// Màn hình thông báo.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;
  bool _notificationsEnabled = true;

  final _getNotificationsEnabled = GetNotificationsEnabled(DI.preferenceRepository);
  final _setNotificationsEnabled = SetNotificationsEnabled(DI.preferenceRepository);
  final _markAsReadUseCase = MarkNotificationAsRead(DI.notificationRepository);
  final _markAllAsReadUseCase = MarkAllNotificationsAsRead(DI.notificationRepository);
  StreamSubscription<List<domain.NotificationEntity>>? _notificationSubscription;
  Timer? _timeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadNotificationSettings();
    _listenToRealtimeNotifications();
    _startTimeUpdateTimer();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  void _startTimeUpdateTimer() {
    // Cập nhật thời gian mỗi phút
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _listenToRealtimeNotifications() {
    // Lắng nghe thông báo real-time
    _notificationSubscription = NotificationRealtimeService.notificationStream.listen((entities) {
      if (mounted) {
        setState(() {
          // Convert từ NotificationEntity sang NotificationItem cho UI
          _notifications = entities.map((e) => _entityToItem(e)).toList();
          _isLoading = false;
        });
      }
    });
  }

  /// Convert NotificationEntity sang NotificationItem cho UI
  NotificationItem _entityToItem(domain.NotificationEntity entity) {
    return NotificationItem(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      time: entity.createdAt,
      isRead: entity.isRead,
      type: _mapNotificationType(entity.type),
    );
  }

  /// Map NotificationType từ domain sang presentation
  NotificationType _mapNotificationType(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.transaction:
        return NotificationType.transaction;
      case domain.NotificationType.reminder:
        return NotificationType.reminder;
      case domain.NotificationType.summary:
        return NotificationType.summary;
      case domain.NotificationType.alert:
        return NotificationType.alert;
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = await _getNotificationsEnabled();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
        });
      }
    } catch (e) {
      // Nếu lỗi, giữ giá trị mặc định
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Đảm bảo service đã start
      await NotificationRealtimeService.startListening();
      
      // Reload notifications và trạng thái đã đọc
      await NotificationRealtimeService.reloadNotifications();
      
      // Đợi một chút để stream có dữ liệu
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Stream sẽ tự động cập nhật _notifications qua _listenToRealtimeNotifications
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Không thể tải thông báo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
        actions: [
          if (!_isLoading && unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Đọc tất cả',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.gray700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Settings section
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bật thông báo',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray900,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _notificationsEnabled
                                    ? 'Bạn sẽ nhận thông báo về giao dịch và nhắc nhở'
                                    : 'Thông báo đã được tắt',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.gray600,
                                    ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) async {
                              await _setNotificationsEnabled(value);
                              if (mounted) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? 'Đã bật thông báo'
                                          : 'Đã tắt thông báo',
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    // Notifications list
                    Expanded(
                      child: _notifications.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                children: [
                                  if (unreadCount > 0) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                      child: Text(
                                        '$unreadCount thông báo chưa đọc',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.gray600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                  ..._notifications
                                      .map((notification) => _buildNotificationCard(notification))
                                      .toList(),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chưa có thông báo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray500,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Các thông báo mới sẽ xuất hiện ở đây',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray400,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xóa thông báo'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: notification.isRead ? AppColors.gray200 : AppColors.primary.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 1.5,
          ),
        ),
        child: InkWell(
          onTap: () async {
            if (!notification.isRead) {
              await _markAsReadUseCase(notification.id);
              setState(() {
                notification.isRead = true;
              });
              // Reload để sync với repository
              await NotificationRealtimeService.reloadNotifications();
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatTime(notification.time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Icons.receipt_long_outlined;
      case NotificationType.reminder:
        return Icons.notifications_active_outlined;
      case NotificationType.summary:
        return Icons.bar_chart_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return AppColors.primary;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.summary:
        return AppColors.info;
      case NotificationType.alert:
        return AppColors.error;
      case NotificationType.system:
        return AppColors.gray600;
    }
  }

  String _formatTime(DateTime time) {
    // Thời gian từ Supabase là UTC time (21:07), giữ nguyên để hiển thị đúng
    // Không convert sang local time
    final notificationTime = time.isUtc ? time : time.toUtc();
    final now = DateTime.now().toUtc(); // So sánh với UTC time
    
    // So sánh ngày ở UTC timezone
    final today = DateTime.utc(now.year, now.month, now.day);
    final notificationDate = DateTime.utc(
      notificationTime.year,
      notificationTime.month,
      notificationTime.day,
    );
    
    // Nếu cùng ngày: hiển thị giờ:phút UTC từ occurred_at trong Supabase (21:07)
    if (notificationDate == today) {
      final hour = notificationTime.hour.toString().padLeft(2, '0');
      final minute = notificationTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    
    // Nếu thời gian trong tương lai (không nên xảy ra): hiển thị giờ:phút
    if (notificationDate.isAfter(today)) {
      final hour = notificationTime.hour.toString().padLeft(2, '0');
      final minute = notificationTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    
    // Nếu khác ngày: tính số ngày từ occurred_at (UTC)
    final daysDiff = today.difference(notificationDate).inDays;
    
    if (daysDiff == 1) {
      return '1 ngày trước';
    } else if (daysDiff < 7) {
      return '$daysDiff ngày trước';
    } else {
      return '${notificationTime.day}/${notificationTime.month}/${notificationTime.year}';
    }
  }

  Future<void> _markAllAsRead() async {
    final notificationIds = _notifications.map((n) => n.id).toList();
    await _markAllAsReadUseCase(notificationIds);
    setState(() {
      _notifications.forEach((n) => n.isRead = true);
    });
    // Reload để sync với repository
    await NotificationRealtimeService.reloadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  transaction,
  reminder,
  summary,
  alert,
  system,
}
