import 'package:expenses/common/theme.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Tóm tắt số liệu tài chính cho dashboard.
class ExpenseSummary {
  final String totalBalance;
  final String monthlyIncome;
  final String monthlyExpense;
  final String monthlySaved;

  const ExpenseSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySaved,
  });
}

/// Thông tin ví cho màn hình Wallets.
class WalletInfo {
  final String name;
  final String type;
  final String balanceFormatted;
  final String? bankName;

  const WalletInfo({
    required this.name,
    required this.type,
    required this.balanceFormatted,
    this.bankName,
  });
}

/// Tổng chi tiêu theo danh mục trong một khoảng thời gian.
class CategorySpendingSummary {
  final String name;
  final num amount;
  final double percentage;
  final IconData icon;
  final Color color;

  const CategorySpendingSummary({
    required this.name,
    required this.amount,
    required this.percentage,
    this.icon = Icons.category,
    this.color = AppColors.gray500,
  });
}

/// Service đọc dữ liệu tài chính thực từ Supabase.
///
/// Các bảng tham chiếu:
/// - `wallets` (user_id, name, type, balance, is_active)
/// - `transactions` (user_id, wallet_id, category_id, type, amount, occurred_at, note)
/// - `jars` (user_id, name, percentage, balance, color, ...)
class ExpenseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static User? get _currentUser => _client.auth.currentUser;

  static String _formatCurrency(num value) {
    // Định dạng đơn giản theo kiểu Việt Nam, tránh phụ thuộc thêm package.
    final intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final reversedIndex = str.length - i - 1;
      buffer.write(str[i]);
      final isThousand = reversedIndex % 3 == 0 && i != str.length - 1;
      if (isThousand) buffer.write('.');
    }
    return '${buffer.toString()} ₫';
  }

  /// Helper public để format số tiền trong UI khác (analytics).
  static String formatCurrency(num value) => _formatCurrency(value);

  /// Lấy tóm tắt số liệu cho user hiện tại.
  static Future<ExpenseSummary> getSummary() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu tài chính.');
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // 1. Tổng số dư từ bảng wallets
    final walletsRes = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', user.id)
        .eq('is_active', true);

    num totalBalance = 0;
    for (final row in walletsRes) {
      totalBalance += (row['balance'] as num?) ?? 0;
    }

    // 2. Thu/chi trong tháng hiện tại từ bảng transactions
    final txRes = await _client
        .from('transactions')
        .select('type, amount, occurred_at')
        .eq('user_id', user.id)
        .gte('occurred_at', monthStart.toIso8601String());

    num income = 0;
    num expense = 0;

    for (final row in txRes) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      if (type == 'INCOME') {
        income += amount;
      } else if (type == 'EXPENSE') {
        expense += amount;
      }
    }

    final saved = income - expense;

    return ExpenseSummary(
      totalBalance: _formatCurrency(totalBalance),
      monthlyIncome: _formatCurrency(income),
      monthlyExpense: _formatCurrency(expense),
      monthlySaved: _formatCurrency(saved),
    );
  }

  /// Lấy tóm tắt số liệu cho tháng cụ thể.
  static Future<ExpenseSummary> getSummaryForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu tài chính.');
    }

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 1);

    // 1. Tổng số dư từ bảng wallets (luôn lấy hiện tại)
    final walletsRes = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', user.id)
        .eq('is_active', true);

    num totalBalance = 0;
    for (final row in walletsRes) {
      totalBalance += (row['balance'] as num?) ?? 0;
    }

    // 2. Thu/chi trong tháng được chọn
    final txRes = await _client
        .from('transactions')
        .select('type, amount, occurred_at')
        .eq('user_id', user.id)
        .gte('occurred_at', monthStart.toIso8601String())
        .lt('occurred_at', monthEnd.toIso8601String());

    num income = 0;
    num expense = 0;

    for (final row in txRes) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      if (type == 'INCOME') {
        income += amount;
      } else if (type == 'EXPENSE') {
        expense += amount;
      }
    }

    final saved = income - expense;

    return ExpenseSummary(
      totalBalance: _formatCurrency(totalBalance),
      monthlyIncome: _formatCurrency(income),
      monthlyExpense: _formatCurrency(expense),
      monthlySaved: _formatCurrency(saved),
    );
  }

  /// Lấy danh sách giao dịch gần đây cho dashboard / analytics.
  static Future<List<TransactionItemData>> getRecentTransactions({
    int limit = 10,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải giao dịch.');
    }

    final res = await _client
        .from('transactions')
        .select('id, type, amount, note, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false) // Giao dịch gần nhất ở trên
        .limit(limit);

    final list = <TransactionItemData>[];

    for (final row in res as List) {
      final id = row['id'] as String?;
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      final note = (row['note'] as String?) ?? 'Giao dịch';
      // Lấy occurred_at từ Supabase (timestamp with time zone)
      // Supabase trả về UTC time với format: "2025-12-24 21:07:12.039+00"
      // Giữ nguyên UTC time để hiển thị đúng như trong database (không convert sang local)
      final occurredAtStr = row['occurred_at'] as String?;
      DateTime? occurredAt;
      if (occurredAtStr != null) {
        try {
          // Parse ISO 8601 string từ Supabase (UTC time)
          // Format: "2025-12-24T21:07:12.039Z" hoặc "2025-12-24 21:07:12.039+00"
          final parsed = DateTime.parse(occurredAtStr);
          // Giữ nguyên UTC time để hiển thị đúng như trong database (21:07)
          // Không convert sang local time
          if (parsed.isUtc) {
            occurredAt = parsed; // Giữ UTC
          } else if (occurredAtStr.endsWith('+00') || occurredAtStr.endsWith('Z')) {
            // Nếu string có +00 hoặc Z, đảm bảo là UTC
            occurredAt = DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          } else {
            // Nếu không có timezone, giả định là UTC
            occurredAt = parsed.isUtc ? parsed : DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          }
        } catch (e) {
          // Nếu parse lỗi, thử parse lại
          occurredAt = DateTime.tryParse(occurredAtStr);
        }
      }

      final isIncome = type == 'INCOME';
      final categoryName = (row['categories'] as Map?)?['name'] as String? ?? (isIncome ? 'Thu nhập' : 'Chi tiêu');
      final color = isIncome ? AppColors.success : AppColors.error;
      final icon =
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

      // Format date và time
      String timeLabel = '';
      String dateLabel = '';
      if (occurredAt != null) {
        timeLabel = '${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
        dateLabel = '${occurredAt.day}/${occurredAt.month}/${occurredAt.year}';
      }

      list.add(
        TransactionItemData(
          id: id,
          title: note,
          category: categoryName,
          amount: '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
          icon: icon,
          color: color,
          time: '$timeLabel - $dateLabel', // Hiển thị cả giờ và ngày
          occurredAt: occurredAt, // Lưu để nhóm theo tháng
        ),
      );
    }

    if (list.isEmpty) {
      return [];
    }

    return list;
  }

  /// Lấy giao dịch theo tháng/năm (dành cho màn All Transactions).
  static Future<List<TransactionItemData>> getTransactionsByMonth({
    required int year,
    required int month,
    int limit = 1000,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải giao dịch.');
    }

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final res = await _client
        .from('transactions')
        .select('type, amount, note, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String())
        .order('occurred_at', ascending: false)
        .limit(limit);

    final list = <TransactionItemData>[];

    for (final row in res as List) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      final note = (row['note'] as String?) ?? 'Giao dịch';
      // Lấy occurred_at từ Supabase (timestamp with time zone)
      // Supabase trả về UTC time với format: "2025-12-24 21:07:12.039+00"
      // Giữ nguyên UTC time để hiển thị đúng như trong database (không convert sang local)
      final occurredAtStr = row['occurred_at'] as String?;
      DateTime? occurredAt;
      if (occurredAtStr != null) {
        try {
          // Parse ISO 8601 string từ Supabase (UTC time)
          // Format: "2025-12-24T21:07:12.039Z" hoặc "2025-12-24 21:07:12.039+00"
          final parsed = DateTime.parse(occurredAtStr);
          // Giữ nguyên UTC time để hiển thị đúng như trong database (21:07)
          // Không convert sang local time
          if (parsed.isUtc) {
            occurredAt = parsed; // Giữ UTC
          } else if (occurredAtStr.endsWith('+00') || occurredAtStr.endsWith('Z')) {
            // Nếu string có +00 hoặc Z, đảm bảo là UTC
            occurredAt = DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          } else {
            // Nếu không có timezone, giả định là UTC
            occurredAt = parsed.isUtc ? parsed : DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          }
        } catch (e) {
          // Nếu parse lỗi, thử parse lại
          occurredAt = DateTime.tryParse(occurredAtStr);
        }
      }

      final isIncome = type == 'INCOME';
      final categoryName = (row['categories'] as Map?)?['name'] as String? ??
          (isIncome ? 'Thu nhập' : 'Chi tiêu');
      final color = isIncome ? AppColors.success : AppColors.error;
      final icon =
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

      // Format date và time
      String timeLabel = '';
      String dateLabel = '';
      if (occurredAt != null) {
        timeLabel =
            '${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
        dateLabel =
            '${occurredAt.day}/${occurredAt.month}/${occurredAt.year}';
      }

      list.add(
        TransactionItemData(
          title: note,
          category: categoryName,
          amount: '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
          icon: icon,
          color: color,
          time: '$timeLabel - $dateLabel',
          occurredAt: occurredAt,
        ),
      );
    }

    return list;
  }

  /// Lấy danh sách ví cho màn hình Wallets.
  static Future<List<WalletInfo>> getWallets() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải ví.');
    }

    final res = await _client
        .from('wallets')
        .select('name, type, balance, bank_name, is_active')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    final list = <WalletInfo>[];

    for (final row in res) {
      final name = (row['name'] as String?) ?? 'Ví không tên';
      final type = (row['type'] as String?) ?? 'Unknown';
      final balance = (row['balance'] as num?) ?? 0;
      final bankName = row['bank_name'] as String?;
      list.add(
        WalletInfo(
          name: name,
          type: type,
          balanceFormatted: _formatCurrency(balance),
          bankName: bankName,
        ),
      );
    }

    return list;
  }

  /// Lấy cấu hình 6 hũ tài chính từ bảng `jars`.
  ///
  /// Nếu user chưa có, trả về danh sách rỗng.
  static Future<List<JarData>> getJars() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải 6 hũ tài chính.');
    }

    final res = await _client
        .from('jars')
        .select('name, balance, percentage')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    final list = <JarData>[];
    final colors = <Color>[
      AppColors.error,
      AppColors.info,
      AppColors.warning,
      AppColors.primary,
      AppColors.success,
      AppColors.secondary,
    ];

    for (var i = 0; i < res.length; i++) {
      final row = res[i];
      final name = (row['name'] as String?) ?? 'Jar';
      final percentage = (row['percentage'] as int?) ?? 0;
      final balance = (row['balance'] as num?) ?? 0;
      final color = colors[i % colors.length];

      list.add(
        JarData(
          name: name,
          amount: _formatCurrency(balance),
          percentage: '$percentage%',
          icon: Icons.savings,
          color: color,
          progress: (percentage / 100).clamp(0.0, 1.0),
        ),
      );
    }

    if (list.isEmpty) {
      return [];
    }

    return list;
  }

  /// Tính tổng thu/chi trong khoảng thời gian theo type.
  static Future<num> _sumAmountInRange({
    required String userId,
    required DateTime start,
    required DateTime end,
    required String type, // 'INCOME' hoặc 'EXPENSE'
  }) async {
    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    num total = 0;
    for (final row in res as List) {
      total += (row['amount'] as num?) ?? 0;
    }
    return total;
  }

  /// So sánh thu/chi giữa hai tháng.
  static Future<MonthlyComparison> getMonthlyComparison() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu so sánh tháng.');
    }

    final now = DateTime.now();
    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 1);

    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final previousStart = DateTime(prevYear, prevMonth, 1);
    final previousEnd = DateTime(now.year, now.month, 1);

    final userId = user.id;

    final prevIncome = await _sumAmountInRange(
      userId: userId,
      start: previousStart,
      end: previousEnd,
      type: 'INCOME',
    );
    final prevExpense = await _sumAmountInRange(
      userId: userId,
      start: previousStart,
      end: previousEnd,
      type: 'EXPENSE',
    );

    final currIncome = await _sumAmountInRange(
      userId: userId,
      start: currentStart,
      end: currentEnd,
      type: 'INCOME',
    );
    final currExpense = await _sumAmountInRange(
      userId: userId,
      start: currentStart,
      end: currentEnd,
      type: 'EXPENSE',
    );

    String monthLabel(int m) => 'Tháng $m';

    return MonthlyComparison(
      previousMonthLabel: monthLabel(previousStart.month),
      currentMonthLabel: monthLabel(currentStart.month),
      previousIncome: _formatCurrency(prevIncome),
      previousExpense: _formatCurrency(prevExpense),
      currentIncome: _formatCurrency(currIncome),
      currentExpense: _formatCurrency(currExpense),
    );
  }

  /// Lấy xu hướng chi tiêu theo tuần / tháng / năm.
  static Future<List<SpendingTrendItem>> getSpendingTrends() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải xu hướng chi tiêu.');
    }

    final now = DateTime.now();

    // Tuần này / tuần trước
    final thisWeekStart =
        now.subtract(Duration(days: now.weekday - 1)); // thứ 2 tuần này
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));

    // Tháng này / tháng trước
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 1);
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final lastMonthStart = DateTime(prevYear, prevMonth, 1);
    final lastMonthEnd = thisMonthStart;

    // Năm nay / năm trước
    final thisYearStart = DateTime(now.year, 1, 1);
    final thisYearEnd = DateTime(now.year + 1, 1, 1);
    final lastYearStart = DateTime(now.year - 1, 1, 1);
    final lastYearEnd = thisYearStart;

    final userId = user.id;

    Future<num> sumExpense(DateTime s, DateTime e) => _sumAmountInRange(
          userId: userId,
          start: s,
          end: e,
          type: 'EXPENSE',
        );

    final thisWeek = await sumExpense(thisWeekStart, thisWeekEnd);
    final lastWeek = await sumExpense(lastWeekStart, lastWeekEnd);

    final thisMonth = await sumExpense(thisMonthStart, thisMonthEnd);
    final lastMonth = await sumExpense(lastMonthStart, lastMonthEnd);

    final thisYear = await sumExpense(thisYearStart, thisYearEnd);
    final lastYear = await sumExpense(lastYearStart, lastYearEnd);

    String pct(num current, num previous) {
      if (previous <= 0) return '0%';
      final p = ((current - previous) / previous * 100).abs();
      return '${p.toStringAsFixed(1)}%';
    }

    bool isIncrease(num current, num previous) => current > previous;


    return [
      SpendingTrendItem(
        label: 'Tuần này',
        amount: _formatCurrency(thisWeek),
        changePercent: pct(thisWeek, lastWeek),
        isIncrease: isIncrease(thisWeek, lastWeek),
      ),
      SpendingTrendItem(
        label: 'Tháng này',
        amount: _formatCurrency(thisMonth),
        changePercent: pct(thisMonth, lastMonth),
        isIncrease: isIncrease(thisMonth, lastMonth),
      ),
      SpendingTrendItem(
        label: 'Năm này',
        amount: _formatCurrency(thisYear),
        changePercent: pct(thisYear, lastYear),
        isIncrease: isIncrease(thisYear, lastYear),
      ),
    ];
  }

  /// Lấy xu hướng chi tiêu cho tháng cụ thể.
  static Future<List<SpendingTrendItem>> getSpendingTrendsForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải xu hướng chi tiêu.');
    }

    // Tính tháng trước
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;

    // Tháng được chọn
    final selectedMonthStart = DateTime(year, month, 1);
    final selectedMonthEnd = DateTime(year, month + 1, 1);

    // Tháng trước
    final prevMonthStart = DateTime(prevYear, prevMonth, 1);
    final prevMonthEnd = selectedMonthStart;

    // Năm được chọn
    final selectedYearStart = DateTime(year, 1, 1);
    final selectedYearEnd = DateTime(year + 1, 1, 1);

    // Năm trước
    final prevYearStart = DateTime(year - 1, 1, 1);
    final prevYearEnd = selectedYearStart;

    // Tuần này (tính từ tháng được chọn)
    final now = DateTime(year, month, 15); // Giữa tháng để tính tuần
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    final userId = user.id;

    Future<num> sumExpense(DateTime s, DateTime e) => _sumAmountInRange(
          userId: userId,
          start: s,
          end: e,
          type: 'EXPENSE',
        );

    final thisWeek = await sumExpense(thisWeekStart, thisWeekEnd);
    final lastWeek = await sumExpense(lastWeekStart, lastWeekEnd);

    final thisMonth = await sumExpense(selectedMonthStart, selectedMonthEnd);
    final lastMonth = await sumExpense(prevMonthStart, prevMonthEnd);

    final thisYear = await sumExpense(selectedYearStart, selectedYearEnd);
    final lastYear = await sumExpense(prevYearStart, prevYearEnd);

    String pct(num current, num previous) {
      if (previous <= 0) return '0%';
      final p = ((current - previous) / previous * 100).abs();
      return '${p.toStringAsFixed(1)}%';
    }

    bool isIncrease(num current, num previous) => current > previous;

    return [
      SpendingTrendItem(
        label: 'Tuần này',
        amount: _formatCurrency(thisWeek),
        changePercent: pct(thisWeek, lastWeek),
        isIncrease: isIncrease(thisWeek, lastWeek),
      ),
      SpendingTrendItem(
        label: 'Tháng này',
        amount: _formatCurrency(thisMonth),
        changePercent: pct(thisMonth, lastMonth),
        isIncrease: isIncrease(thisMonth, lastMonth),
      ),
      SpendingTrendItem(
        label: 'Năm này',
        amount: _formatCurrency(thisYear),
        changePercent: pct(thisYear, lastYear),
        isIncrease: isIncrease(thisYear, lastYear),
      ),
    ];
  }

  /// Lấy income và expense cho một tháng cụ thể.
  static Future<Map<String, num>> getIncomeExpenseForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return {'income': 0, 'expense': 0};
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final income = await _sumAmountInRange(
      userId: user.id,
      start: start,
      end: end,
      type: 'INCOME',
    );
    final expense = await _sumAmountInRange(
      userId: user.id,
      start: start,
      end: end,
      type: 'EXPENSE',
    );

    return {'income': income, 'expense': expense};
  }

  /// So sánh income/expense giữa tháng hiện tại và tháng trước.
  static Future<Map<String, dynamic>> getMonthComparison({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return {
        'current': {'income': 0, 'expense': 0},
        'previous': {'income': 0, 'expense': 0},
        'change': {'income': 0, 'expense': 0},
      };
    }

    final current = await getIncomeExpenseForMonth(year: year, month: month);

    // Tính tháng trước
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final previous = await getIncomeExpenseForMonth(year: prevYear, month: prevMonth);

    final incomeChange = current['income']! - previous['income']!;
    final expenseChange = current['expense']! - previous['expense']!;

    return {
      'current': current,
      'previous': previous,
      'change': {'income': incomeChange, 'expense': expenseChange},
    };
  }

  /// Lấy chi tiêu theo danh mục cho một tháng cụ thể.
  static Future<List<CategorySpendingSummary>> getCategorySpendingForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return const [];
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    final Map<String, num> byCategory = {};

    for (final row in res) {
      final type = row['type'] as String?;
      if (type != 'EXPENSE') continue;

      final cat = (row['categories'] as Map?)?['name'] as String? ?? 'Chưa phân loại';
      final amount = (row['amount'] as num?) ?? 0;
      byCategory[cat] = (byCategory[cat] ?? 0) + amount;
    }

    final total = byCategory.values.fold<num>(0, (p, e) => p + e);

    if (total <= 0) {
      return const [];
    }

    // Map tên category với icon và color mặc định
    final defaultCategoryMap = _getDefaultCategoryMap();

    final list = byCategory.entries
        .map(
          (e) {
            final catName = e.key.toLowerCase();
            final defaultInfo = defaultCategoryMap[catName];
            
            // Dùng icon và color từ default map, nếu không có thì dùng mặc định
            final icon = defaultInfo?['icon'] as IconData? ?? Icons.category;
            final color = defaultInfo?['color'] as Color? ?? AppColors.gray500;
            
            return CategorySpendingSummary(
              name: e.key,
              amount: e.value,
              percentage: (e.value * 100.0) / total,
              icon: icon,
              color: color,
            );
          },
        )
        .toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  /// Lấy danh sách thu nhập theo danh mục trong tháng.
  static Future<List<CategorySpendingSummary>> getCategoryIncomeForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return const [];
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    final Map<String, num> byCategory = {};

    for (final row in res) {
      final type = row['type'] as String?;
      if (type != 'INCOME') continue; // Chỉ lấy INCOME

      final cat = (row['categories'] as Map?)?['name'] as String? ?? 'Chưa phân loại';
      final amount = (row['amount'] as num?) ?? 0;
      byCategory[cat] = (byCategory[cat] ?? 0) + amount;
    }

    final total = byCategory.values.fold<num>(0, (p, e) => p + e);

    if (total <= 0) {
      return const [];
    }

    // Map tên category với icon và color mặc định cho thu nhập
    final defaultCategoryMap = _getDefaultIncomeCategoryMap();

    final list = byCategory.entries
        .map(
          (e) {
            final catName = e.key.toLowerCase();
            final defaultInfo = defaultCategoryMap[catName];
            
            // Dùng icon và color từ default map, nếu không có thì dùng mặc định
            final icon = defaultInfo?['icon'] as IconData? ?? Icons.category;
            final color = defaultInfo?['color'] as Color? ?? AppColors.success;
            
            return CategorySpendingSummary(
              name: e.key,
              amount: e.value,
              percentage: (e.value * 100.0) / total,
              icon: icon,
              color: color,
            );
          },
        )
        .toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  /// Map các category mặc định với icon và color
  static Map<String, Map<String, dynamic>> _getDefaultCategoryMap() {
    return {
      'chợ, siêu thị': {
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'ăn uống': {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFFFEB3B),
      },
      'di chuyển': {
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF81D4FA),
      },
      'mua sắm': {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFF48FB1),
      },
      'giải trí': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'làm đẹp': {
        'icon': Icons.brush_outlined,
        'color': const Color(0xFFE91E63),
      },
      'sức khỏe': {
        'icon': Icons.favorite_outlined,
        'color': const Color(0xFFFF5252),
      },
      'từ thiện': {
        'icon': Icons.volunteer_activism_outlined,
        'color': const Color(0xFFFFAB91),
      },
      'hóa đơn': {
        'icon': Icons.receipt_long_outlined,
        'color': const Color(0xFF10B981),
      },
      'nhà cửa': {
        'icon': Icons.home_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      'người thân': {
        'icon': Icons.people_outline,
        'color': const Color(0xFFF48FB1),
      },
    };
  }

  /// Map các category thu nhập mặc định với icon và color
  static Map<String, Map<String, dynamic>> _getDefaultIncomeCategoryMap() {
    return {
      'lương': {
        'icon': Icons.work_outline,
        'color': const Color(0xFF66BB6A),
      },
      'thưởng': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFF29B6F6),
      },
      'thu nhập phụ': {
        'icon': Icons.trending_up_outlined,
        'color': const Color(0xFF26A69A),
      },
      'khác': {
        'icon': Icons.more_horiz,
        'color': AppColors.gray500,
      },
    };
  }

  /// Lấy danh sách chi tiêu theo danh mục trong tháng hiện tại từ cột `category_name`.
  static Future<List<CategorySpendingSummary>>
      getCategorySpendingForCurrentMonth() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải chi tiêu theo danh mục.');
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    final Map<String, num> byCategory = {};

    for (final row in res as List) {
      final type = row['type'] as String?;
      if (type != 'EXPENSE') continue;

      final cat = (row['categories'] as Map?)?['name'] as String? ?? 'Chưa phân loại';
      final amount = (row['amount'] as num?) ?? 0;
      byCategory[cat] = (byCategory[cat] ?? 0) + amount;
    }

    final total = byCategory.values.fold<num>(0, (p, e) => p + e);

    if (total <= 0) {
      return [];
    }

    final list = byCategory.entries
        .map(
          (e) => CategorySpendingSummary(
            name: e.key,
            amount: e.value,
            percentage: (e.value * 100.0) / total,
            icon: Icons.category,
            color: AppColors.gray500,
          ),
        )
        .toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}

/// So sánh thu/chi giữa hai tháng.
class MonthlyComparison {
  final String previousMonthLabel;
  final String currentMonthLabel;
  final String previousIncome;
  final String previousExpense;
  final String currentIncome;
  final String currentExpense;

  const MonthlyComparison({
    required this.previousMonthLabel,
    required this.currentMonthLabel,
    required this.previousIncome,
    required this.previousExpense,
    required this.currentIncome,
    required this.currentExpense,
  });
}

/// Một dòng xu hướng chi tiêu (tuần/tháng/năm).
class SpendingTrendItem {
  final String label;
  final String amount;
  final String changePercent;
  final bool isIncrease; // true: chi tiêu tăng, false: giảm

  const SpendingTrendItem({
    required this.label,
    required this.amount,
    required this.changePercent,
    required this.isIncrease,
  });
}
