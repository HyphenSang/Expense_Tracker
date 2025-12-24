/// Repository interface cho Expense/Analytics trong domain layer
abstract class ExpenseRepository {
  /// Lấy tóm tắt số liệu tài chính
  Future<ExpenseSummary> getSummary();

  /// Lấy tóm tắt số liệu cho tháng cụ thể
  Future<ExpenseSummary> getSummaryForMonth({
    required int year,
    required int month,
  });

  /// Lấy thu/chi cho tháng
  Future<Map<String, num>> getIncomeExpenseForMonth({
    required int year,
    required int month,
  });

  /// So sánh tháng hiện tại với tháng trước
  Future<MonthlyComparison> getMonthComparison({
    required int year,
    required int month,
  });

  /// Lấy chi tiêu theo danh mục trong tháng
  Future<List<CategorySpendingSummary>> getCategorySpendingForMonth({
    required int year,
    required int month,
  });

  /// Lấy thu nhập theo danh mục trong tháng
  Future<List<CategorySpendingSummary>> getCategoryIncomeForMonth({
    required int year,
    required int month,
  });

  /// Lấy xu hướng chi tiêu cho tháng
  Future<List<SpendingTrendItem>> getSpendingTrendsForMonth({
    required int year,
    required int month,
  });
}

/// Tóm tắt số liệu tài chính
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

/// So sánh tháng hiện tại với tháng trước
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

/// Tổng chi tiêu theo danh mục
class CategorySpendingSummary {
  final String name;
  final num amount;
  final double percentage;
  final String? icon; // Icon name/identifier
  final String? color; // Color hex code

  const CategorySpendingSummary({
    required this.name,
    required this.amount,
    required this.percentage,
    this.icon,
    this.color,
  });
}

/// Xu hướng chi tiêu
class SpendingTrendItem {
  final String label;
  final num amount;
  final DateTime date;

  const SpendingTrendItem({
    required this.label,
    required this.amount,
    required this.date,
  });
}

