
/// Service phân tích và dự đoán ngân sách
class BudgetInsightService {

  /// Tính toán thông tin chi tiết về ngân sách
  static Future<BudgetInsight> calculateInsight({
    required String userId,
    required String budgetId,
    required num limitAmount,
    required num spentAmount,
    required DateTime startDate,
    DateTime? endDate,
    required String period,
  }) async {
    final now = DateTime.now();
    
    // Tính số ngày đã trôi qua và tổng số ngày
    int daysPassed;
    int totalDays;
    
    switch (period) {
      case 'WEEKLY':
        final daysFromMonday = now.weekday - 1;
        final weekStart = now.subtract(Duration(days: daysFromMonday));
        daysPassed = now.difference(weekStart).inDays;
        totalDays = 7;
        break;
      case 'MONTHLY':
        final monthStart = DateTime(now.year, now.month, 1);
        daysPassed = now.difference(monthStart).inDays + 1;
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        totalDays = nextMonth.difference(monthStart).inDays;
        break;
      case 'YEARLY':
        final yearStart = DateTime(now.year, 1, 1);
        daysPassed = now.difference(yearStart).inDays + 1;
        totalDays = DateTime(now.year + 1, 1, 1).difference(yearStart).inDays;
        break;
      default:
        if (endDate != null) {
          totalDays = endDate.difference(startDate).inDays;
          daysPassed = now.difference(startDate).inDays + 1;
        } else {
          totalDays = 30;
          daysPassed = now.difference(startDate).inDays + 1;
        }
    }

    // Tính tốc độ chi tiêu trung bình
    final averageSpendingPerDay = daysPassed > 0 ? spentAmount / daysPassed : 0;
    
    // Dự đoán chi tiêu cuối kỳ
    final projectedSpending = averageSpendingPerDay * totalDays;
    
    // Tính số ngày còn lại
    final daysRemaining = totalDays - daysPassed;
    
    // Tính số tiền còn lại
    final remainingAmount = limitAmount - spentAmount;
    
    // Tính số tiền cần chi mỗi ngày để đạt mục tiêu
    final requiredSpendingPerDay = daysRemaining > 0 
        ? remainingAmount / daysRemaining 
        : 0;
    
    // Tính phần trăm đã dùng
    final percentage = limitAmount > 0 ? (spentAmount / limitAmount) * 100 : 0;
    
    // Xác định trạng thái
    String status;
    if (percentage >= 100) {
      status = 'exceeded';
    } else if (percentage >= 90) {
      status = 'critical';
    } else if (percentage >= 75) {
      status = 'warning';
    } else {
      status = 'ok';
    }
    
    // Tính số tiền vượt (nếu có)
    final overBudgetAmount = spentAmount > limitAmount 
        ? (spentAmount - limitAmount) 
        : 0;
    
    // Dự đoán ngày hết ngân sách
    DateTime? projectedExhaustionDate;
    if (averageSpendingPerDay > 0 && spentAmount < limitAmount) {
      final remaining = limitAmount - spentAmount;
      final daysUntilExhaustion = (remaining / averageSpendingPerDay).ceil();
      projectedExhaustionDate = now.add(Duration(days: daysUntilExhaustion));
    }

    return BudgetInsight(
      budgetId: budgetId,
      limitAmount: limitAmount,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      percentage: percentage.toDouble(),
      daysPassed: daysPassed,
      totalDays: totalDays,
      daysRemaining: daysRemaining,
      averageSpendingPerDay: averageSpendingPerDay,
      requiredSpendingPerDay: requiredSpendingPerDay,
      projectedSpending: projectedSpending,
      projectedExhaustionDate: projectedExhaustionDate,
      status: status,
      overBudgetAmount: overBudgetAmount,
    );
  }

  /// Tạo thông điệp thân thiện dựa trên insight
  static String generateFriendlyMessage(BudgetInsight insight) {
    if (insight.status == 'exceeded') {
      return 'Bạn đã vượt ngân sách ${_formatCurrency(insight.overBudgetAmount)}. '
          'Không sao, lần sau cố gắng hơn nhé! 💪';
    } else if (insight.status == 'critical') {
      return 'Bạn đã dùng ${insight.percentage.toStringAsFixed(0)}% ngân sách. '
          'Còn ${insight.daysRemaining} ngày nữa, hãy chi tiêu cẩn thận nhé!';
    } else if (insight.status == 'warning') {
      return 'Bạn đã dùng ${insight.percentage.toStringAsFixed(0)}% ngân sách. '
          'Còn ${_formatCurrency(insight.remainingAmount)} và ${insight.daysRemaining} ngày nữa.';
    } else {
      if (insight.projectedExhaustionDate != null) {
        final daysUntilExhaustion = insight.projectedExhaustionDate!
            .difference(DateTime.now())
            .inDays;
        if (daysUntilExhaustion < insight.daysRemaining) {
          return 'Nếu tiếp tục chi tiêu như hiện tại, bạn sẽ hết ngân sách trong $daysUntilExhaustion ngày nữa. '
              'Hãy giảm chi tiêu ${_formatCurrency(insight.averageSpendingPerDay - insight.requiredSpendingPerDay)}/ngày để đạt mục tiêu.';
        }
      }
      return 'Bạn đã chi ${_formatCurrency(insight.spentAmount)}/${_formatCurrency(insight.limitAmount)}, '
          'còn ${_formatCurrency(insight.remainingAmount)} và ${insight.daysRemaining} ngày nữa.';
    }
  }

  /// Tạo gợi ý điều chỉnh
  static String? generateSuggestion(BudgetInsight insight) {
    if (insight.status == 'exceeded') {
      return 'Bạn có thể bù từ ngân sách khác còn dư, hoặc điều chỉnh ngân sách cho phù hợp.';
    } else if (insight.status == 'critical') {
      if (insight.requiredSpendingPerDay < insight.averageSpendingPerDay) {
        final reduceAmount = insight.averageSpendingPerDay - insight.requiredSpendingPerDay;
        return 'Bạn có thể giảm chi tiêu ${_formatCurrency(reduceAmount)}/ngày để đạt mục tiêu.';
      }
    } else if (insight.status == 'warning') {
      if (insight.projectedSpending > insight.limitAmount) {
        final overAmount = insight.projectedSpending - insight.limitAmount;
        return 'Nếu tiếp tục chi tiêu như hiện tại, bạn sẽ vượt ${_formatCurrency(overAmount)}. '
            'Hãy chú ý nhé!';
      }
    }
    return null;
  }

  static String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toStringAsFixed(0)} ₫';
  }
}

/// Thông tin phân tích ngân sách
class BudgetInsight {
  final String budgetId;
  final num limitAmount;
  final num spentAmount;
  final num remainingAmount;
  final double percentage;
  final int daysPassed;
  final int totalDays;
  final int daysRemaining;
  final num averageSpendingPerDay;
  final num requiredSpendingPerDay;
  final num projectedSpending;
  final DateTime? projectedExhaustionDate;
  final String status; // 'ok', 'warning', 'critical', 'exceeded'
  final num overBudgetAmount;

  BudgetInsight({
    required this.budgetId,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
    required this.daysPassed,
    required this.totalDays,
    required this.daysRemaining,
    required this.averageSpendingPerDay,
    required this.requiredSpendingPerDay,
    required this.projectedSpending,
    this.projectedExhaustionDate,
    required this.status,
    required this.overBudgetAmount,
  });
}

