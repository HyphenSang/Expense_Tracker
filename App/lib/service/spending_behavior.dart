import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service phân tích hành vi chi tiêu
class SpendingBehaviorService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Phân tích thói quen chi tiêu theo ngày trong tuần
  static Future<SpendingPattern> analyzeWeeklyPattern({
    required String userId,
    required String categoryId,
    int monthsBack = 3,
  }) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - monthsBack, 1);
    
    // Lấy tất cả transactions của category này trong 3 tháng gần nhất
    final transactions = await _client
        .from('transactions')
        .select('amount, occurred_at')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('type', 'EXPENSE')
        .gte('occurred_at', startDate.toIso8601String())
        .order('occurred_at', ascending: false);

    // Phân tích theo ngày trong tuần (1 = Monday, 7 = Sunday)
    final Map<int, num> spendingByDay = {};
    final Map<int, int> countByDay = {};
    
    for (final tx in transactions) {
      final occurredAt = DateTime.parse(tx['occurred_at'] as String);
      final dayOfWeek = occurredAt.weekday;
      final amount = (tx['amount'] as num?) ?? 0;
      
      spendingByDay[dayOfWeek] = (spendingByDay[dayOfWeek] ?? 0) + amount;
      countByDay[dayOfWeek] = (countByDay[dayOfWeek] ?? 0) + 1;
    }

    // Tìm ngày chi nhiều nhất
    int? peakDay;
    num maxSpending = 0;
    spendingByDay.forEach((day, amount) {
      if (amount > maxSpending) {
        maxSpending = amount;
        peakDay = day;
      }
    });

    // Tính trung bình
    final totalSpending = spendingByDay.values.fold<num>(0, (sum, amount) => sum + amount);
    final totalCount = countByDay.values.fold<int>(0, (sum, count) => sum + count);
    final averageSpending = totalCount > 0 ? totalSpending / totalCount : 0;

    return SpendingPattern(
      peakDay: peakDay,
      peakDayName: peakDay != null ? _getDayName(peakDay!) : null,
      averageSpending: averageSpending,
      totalTransactions: totalCount,
      message: peakDay != null 
          ? 'Bạn thường chi nhiều vào ${_getDayName(peakDay!)}'
          : 'Chưa có đủ dữ liệu để phân tích',
    );
  }

  /// Phân tích lý do vượt ngân sách trong quá khứ
  static Future<List<OverBudgetHistory>> getOverBudgetHistory({
    required String userId,
    required String budgetId,
    int monthsBack = 3,
  }) async {
    try {
      // Lấy lịch sử vượt ngân sách từ bảng budgets
      // Giả sử có lưu lý do trong over_budget_reason
      final budgets = await _client
          .from('budgets')
          .select('over_budget_amount, over_budget_reason, start_date, end_date')
          .eq('id', budgetId)
          .eq('user_id', userId)
          .not('over_budget_reason', 'is', null)
          .order('start_date', ascending: false)
          .limit(monthsBack * 2); // Mỗi tháng có thể có 2 budgets (weekly)

      return budgets.map<OverBudgetHistory>((budget) {
        return OverBudgetHistory(
          amount: (budget['over_budget_amount'] as num?) ?? 0,
          reason: budget['over_budget_reason'] as String? ?? '',
          date: budget['start_date'] != null 
              ? DateTime.parse(budget['start_date'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Phân tích tốc độ chi tiêu so với bình thường
  static Future<SpendingPace> analyzeSpendingPace({
    required String userId,
    required String categoryId,
    required num currentSpent,
    required num limitAmount,
    required int daysPassed,
    required int totalDays,
  }) async {
    final now = DateTime.now();
    final monthsBack = 3;
    final startDate = DateTime(now.year, now.month - monthsBack, 1);
    
    // Lấy transactions trong 3 tháng trước
    final pastTransactions = await _client
        .from('transactions')
        .select('amount, occurred_at')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('type', 'EXPENSE')
        .gte('occurred_at', startDate.toIso8601String())
        .lt('occurred_at', now.subtract(Duration(days: 30)).toIso8601String());

    // Tính trung bình chi tiêu mỗi ngày trong quá khứ
    num totalPastSpending = 0;
    int totalPastDays = 0;
    
    for (final tx in pastTransactions) {
      totalPastSpending += (tx['amount'] as num?) ?? 0;
    }
    
    // Giả sử mỗi tháng có 30 ngày
    totalPastDays = monthsBack * 30;
    final averagePastSpendingPerDay = totalPastDays > 0 
        ? totalPastSpending / totalPastDays 
        : 0;
    
    // Tính tốc độ hiện tại
    final currentSpendingPerDay = daysPassed > 0 
        ? currentSpent / daysPassed 
        : 0;
    
    // So sánh
    final paceDifference = averagePastSpendingPerDay > 0
        ? ((currentSpendingPerDay - averagePastSpendingPerDay) / averagePastSpendingPerDay) * 100
        : 0;
    
    String paceStatus;
    if (paceDifference > 20) {
      paceStatus = 'fast';
    } else if (paceDifference < -20) {
      paceStatus = 'slow';
    } else {
      paceStatus = 'normal';
    }

    return SpendingPace(
      currentPace: currentSpendingPerDay,
      averagePace: averagePastSpendingPerDay,
      difference: paceDifference.toDouble(),
      status: paceStatus,
      message: paceDifference > 20
          ? 'Bạn đang chi tiêu nhanh hơn bình thường ${paceDifference.toStringAsFixed(0)}%'
          : paceDifference < -20
              ? 'Bạn đang chi tiêu chậm hơn bình thường ${paceDifference.abs().toStringAsFixed(0)}%'
              : 'Bạn đang chi tiêu với tốc độ bình thường',
    );
  }

  static String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }
}

/// Mẫu chi tiêu
class SpendingPattern {
  final int? peakDay;
  final String? peakDayName;
  final num averageSpending;
  final int totalTransactions;
  final String message;

  SpendingPattern({
    this.peakDay,
    this.peakDayName,
    required this.averageSpending,
    required this.totalTransactions,
    required this.message,
  });
}

/// Lịch sử vượt ngân sách
class OverBudgetHistory {
  final num amount;
  final String reason;
  final DateTime date;

  OverBudgetHistory({
    required this.amount,
    required this.reason,
    required this.date,
  });
}

/// Tốc độ chi tiêu
class SpendingPace {
  final num currentPace;
  final num averagePace;
  final double difference; // Phần trăm
  final String status; // 'fast', 'slow', 'normal'
  final String message;

  SpendingPace({
    required this.currentPace,
    required this.averagePace,
    required this.difference,
    required this.status,
    required this.message,
  });
}

