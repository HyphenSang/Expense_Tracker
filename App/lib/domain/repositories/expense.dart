import '../../presentation/widgets/recent_transactions.dart';
import '../../presentation/widgets/jar_data.dart';
import '../../service/expense.dart';
import 'package:flutter/material.dart';

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

  /// Lấy danh sách giao dịch gần đây
  Future<List<TransactionItemData>?> getRecentTransactions({
    int limit = 10,
  });

  /// Lấy giao dịch theo tháng/năm
  Future<List<TransactionItemData>?> getTransactionsByMonth({
    required int year,
    required int month,
    int limit = 1000,
  });

  /// Lấy danh sách ví
  Future<List<WalletInfo>> getWallets();

  /// Lấy danh sách hũ tài chính
  Future<List<JarData>> getJars();
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
  final IconData icon;
  final Color color;

  const CategorySpendingSummary({
    required this.name,
    required this.amount,
    required this.percentage,
    this.icon = Icons.category,
    this.color = const Color(0xFF9E9E9E),
  });
}

/// Xu hướng chi tiêu (sử dụng từ ExpenseService)
/// Note: SpendingTrendItem được định nghĩa trong ExpenseService

