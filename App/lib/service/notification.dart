import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/service/expense.dart';
import 'package:expenses/domain/entities/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service tạo danh sách thông báo dựa trên dữ liệu thật của user.
class NotificationService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static User? get _currentUser => _client.auth.currentUser;

  /// Lấy danh sách thông báo cho user hiện tại.
  ///
  /// Dữ liệu được tổng hợp từ:
  /// - Giao dịch gần đây
  /// - Nhắc nhở ghi chép chi tiêu trong ngày
  /// - Thống kê chi tiêu 7 ngày gần nhất
  /// - Cảnh báo ngân sách theo danh mục trong tháng hiện tại
  static Future<List<NotificationEntity>> getNotifications() async {
    final user = _currentUser;
    if (user == null) return [];

    final notifications = <NotificationEntity>[];

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // 1. Giao dịch gần đây trong 7 ngày (tối đa 20 giao dịch)
    try {
      final recentTx = await ExpenseService.getRecentTransactions(limit: 20);
      for (var tx in recentTx) {
        final occurredAt = tx.occurredAt;
        if (occurredAt == null) continue;

        // Chỉ lấy giao dịch trong 7 ngày gần nhất
        if (occurredAt.isBefore(weekAgo)) continue;

        final isIncome = tx.amount.startsWith('+');
        final title = isIncome ? 'Giao dịch thu nhập mới' : 'Giao dịch chi tiêu mới';
        final message = isIncome
            ? 'Bạn đã nhận ${tx.amount} từ danh mục \"${tx.category}\"'
            : 'Bạn đã chi ${tx.amount} cho \"${tx.category}\"';

        // Sử dụng transaction ID thực tế nếu có, nếu không thì dùng timestamp
        final notificationId = tx.id != null 
            ? 'tx_${tx.id}' 
            : 'tx_${occurredAt.millisecondsSinceEpoch}';

        notifications.add(
          NotificationEntity(
            id: notificationId,
            userId: user.id,
            title: title,
            message: message,
            createdAt: occurredAt,
            isRead: false,
            type: NotificationType.transaction,
          ),
        );
      }
    } catch (_) {
      // Nếu lỗi, bỏ qua phần này để không làm vỡ màn hình Thông báo
    }

    // 2. Nhắc nhở ghi chép chi tiêu hôm nay (nếu chưa có giao dịch trong ngày)
    try {
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final res = await _client
          .from('transactions')
          .select('id')
          .eq('user_id', user.id)
          .gte('occurred_at', todayStart.toIso8601String())
          .lt('occurred_at', tomorrowStart.toIso8601String())
          .limit(1);

      if (res.isEmpty) {
        notifications.add(
          NotificationEntity(
            id: 'reminder_${todayStart.toIso8601String()}',
            userId: user.id,
            title: 'Nhắc nhở',
            message:
                'Bạn chưa ghi lại chi tiêu hôm nay. Hãy cập nhật để theo dõi tốt hơn!',
            createdAt: now,
            isRead: false,
            type: NotificationType.reminder,
          ),
        );
      }
    } catch (_) {
      // Bỏ qua nếu lỗi
    }

    // 3. Thống kê tuần: tổng chi tiêu 7 ngày gần nhất (chỉ hiển thị nếu có giao dịch trong tuần)
    try {
      final weekStart = now.subtract(const Duration(days: 7));

      final res = await _client
          .from('transactions')
          .select('type, amount, occurred_at')
          .eq('user_id', user.id)
          .gte('occurred_at', weekStart.toIso8601String())
          .lt('occurred_at', now.toIso8601String());

      num weeklyExpense = 0;
      for (final row in res as List) {
        final type = row['type'] as String?;
        final amount = (row['amount'] as num?) ?? 0;
        if (type == 'EXPENSE') {
          weeklyExpense += amount;
        }
      }

      if (weeklyExpense > 0) {
        notifications.add(
          NotificationEntity(
            id: 'summary_${weekStart.toIso8601String()}',
            userId: user.id,
            title: 'Thống kê tuần',
            message:
                'Tổng chi tiêu 7 ngày gần đây của bạn là ${ExpenseService.formatCurrency(weeklyExpense)}',
            createdAt: weekStart.add(const Duration(days: 1)), // Thời gian của thống kê
            isRead: true,
            type: NotificationType.summary,
          ),
        );
      }
    } catch (_) {
      // Bỏ qua nếu lỗi
    }

    // 4. Cảnh báo ngân sách theo danh mục trong tháng hiện tại (chỉ hiển thị nếu trong tuần)
    // Bỏ qua phần này vì cảnh báo ngân sách là theo tháng, không phải theo tuần

    // Lọc lại để chỉ giữ các thông báo trong 7 ngày gần nhất
    notifications.removeWhere((notification) {
      return notification.createdAt.isBefore(weekAgo);
    });

    // Sắp xếp thông báo theo thời gian mới nhất ở trên
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }
}


