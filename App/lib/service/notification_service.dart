import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/service/expense_service.dart';
import 'package:expenses/presentation/screens/notifications.dart';
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
  static Future<List<NotificationItem>> getNotifications() async {
    final user = _currentUser;
    if (user == null) return [];

    final notifications = <NotificationItem>[];

    // 1. Giao dịch gần đây (tối đa 3 giao dịch)
    try {
      final recentTx = await ExpenseService.getRecentTransactions(limit: 3);
      for (var i = 0; i < recentTx.length; i++) {
        final tx = recentTx[i];
        final occurredAt = tx.occurredAt;
        if (occurredAt == null) continue;

        final isIncome = tx.amount.startsWith('+');
        final title = isIncome ? 'Giao dịch thu nhập mới' : 'Giao dịch chi tiêu mới';
        final message = isIncome
            ? 'Bạn đã nhận ${tx.amount} từ danh mục \"${tx.category}\"'
            : 'Bạn đã chi ${tx.amount} cho \"${tx.category}\"';

        notifications.add(
          NotificationItem(
            id: 'tx_${occurredAt.millisecondsSinceEpoch}_$i',
            title: title,
            message: message,
            time: occurredAt,
            isRead: false,
            type: NotificationType.transaction,
          ),
        );
      }
    } catch (_) {
      // Nếu lỗi, bỏ qua phần này để không làm vỡ màn hình Thông báo
    }

    final now = DateTime.now();

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
          NotificationItem(
            id: 'reminder_${todayStart.toIso8601String()}',
            title: 'Nhắc nhở',
            message:
                'Bạn chưa ghi lại chi tiêu hôm nay. Hãy cập nhật để theo dõi tốt hơn!',
            time: now,
            isRead: false,
            type: NotificationType.reminder,
          ),
        );
      }
    } catch (_) {
      // Bỏ qua nếu lỗi
    }

    // 3. Thống kê tuần: tổng chi tiêu 7 ngày gần nhất
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
          NotificationItem(
            id: 'summary_${weekStart.toIso8601String()}',
            title: 'Thống kê tuần',
            message:
                'Tổng chi tiêu 7 ngày gần đây của bạn là ${ExpenseService.formatCurrency(weeklyExpense)}',
            time: now,
            isRead: true,
            type: NotificationType.summary,
          ),
        );
      }
    } catch (_) {
      // Bỏ qua nếu lỗi
    }

    // 4. Cảnh báo ngân sách theo danh mục trong tháng hiện tại
    try {
      final monthCategories =
          await ExpenseService.getCategorySpendingForMonth(
        year: now.year,
        month: now.month,
      );

      if (monthCategories.isNotEmpty) {
        // Lấy danh mục có tỷ lệ chi tiêu cao nhất
        monthCategories.sort((a, b) => b.percentage.compareTo(a.percentage));
        final top = monthCategories.first;

        // Nếu danh mục này chiếm >= 80% tổng chi tiêu thì cảnh báo
        if (top.percentage >= 80) {
          notifications.add(
            NotificationItem(
              id: 'alert_${now.year}_${now.month}_${top.name}',
              title: 'Cảnh báo ngân sách',
              message:
                  'Bạn đã chi tiêu ${top.percentage.toStringAsFixed(0)}% ngân sách tháng này cho danh mục \"${top.name}\"',
              time: now,
              isRead: true,
              type: NotificationType.alert,
            ),
          );
        }
      }
    } catch (_) {
      // Bỏ qua nếu lỗi
    }

    // Sắp xếp thông báo theo thời gian mới nhất ở trên
    notifications.sort((a, b) => b.time.compareTo(a.time));

    return notifications;
  }
}


