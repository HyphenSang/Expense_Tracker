import '../repositories/expense.dart';
import '../../presentation/widgets/recent_transactions.dart';
import '../../service/expense.dart' hide MonthlyComparison, ExpenseSummary, CategorySpendingSummary;
import '../../data/sample_data.dart';

/// Use case để lấy giao dịch
class GetTransactions {
  final ExpenseRepository _repository;

  GetTransactions(this._repository);

  /// Lấy danh sách giao dịch gần đây
  Future<List<TransactionItemData>?> getRecent({int limit = 10}) async {
    return await _repository.getRecentTransactions(limit: limit);
  }

  /// Lấy giao dịch theo tháng/năm
  Future<List<TransactionItemData>?> byMonth({
    required int year,
    required int month,
    int limit = 1000,
  }) async {
    return await _repository.getTransactionsByMonth(
      year: year,
      month: month,
      limit: limit,
    );
  }
}

/// Use case để lấy dữ liệu phân tích/thống kê
class GetAnalytics {
  final ExpenseRepository _repository;

  GetAnalytics(this._repository);

  /// Lấy thu/chi cho tháng
  Future<Map<String, num>> getIncomeExpense({
    required int year,
    required int month,
  }) async {
    return await _repository.getIncomeExpenseForMonth(
      year: year,
      month: month,
    );
  }

  /// Lấy xu hướng chi tiêu cho tháng
  Future<List<SpendingTrendItem>> getSpendingTrends({
    required int year,
    required int month,
  }) async {
    return await _repository.getSpendingTrendsForMonth(
      year: year,
      month: month,
    );
  }

  /// So sánh tháng hiện tại với tháng trước
  Future<MonthlyComparison> getMonthComparison({
    required int year,
    required int month,
  }) async {
    return await _repository.getMonthComparison(year: year, month: month);
  }
}

/// Use case để lấy dữ liệu theo danh mục (chi tiêu hoặc thu nhập)
class GetCategoryData {
  final ExpenseRepository _repository;

  GetCategoryData(this._repository);

  /// Lấy chi tiêu theo danh mục trong tháng
  Future<List<CategorySpendingSummary>> getSpending({
    required int year,
    required int month,
  }) async {
    return await _repository.getCategorySpendingForMonth(
      year: year,
      month: month,
    );
  }

  /// Lấy thu nhập theo danh mục trong tháng
  Future<List<CategorySpendingSummary>> getIncome({
    required int year,
    required int month,
  }) async {
    return await _repository.getCategoryIncomeForMonth(
      year: year,
      month: month,
    );
  }
}

/// Use case để lấy tóm tắt số liệu tài chính
class GetExpenseSummary {
  final ExpenseRepository _repository;

  GetExpenseSummary(this._repository);

  /// Lấy tóm tắt số liệu cho tháng hiện tại
  Future<ExpenseSummary> call() async {
    return await _repository.getSummary();
  }

  /// Lấy tóm tắt số liệu cho tháng cụ thể
  Future<ExpenseSummary> forMonth({
    required int year,
    required int month,
  }) async {
    return await _repository.getSummaryForMonth(year: year, month: month);
  }
}

/// Use case để lấy danh sách ví
class GetWallets {
  final ExpenseRepository _repository;

  GetWallets(this._repository);

  Future<List<WalletInfo>> call() async {
    return await _repository.getWallets();
  }
}

/// Use case để lấy danh sách hũ
class GetJars {
  final ExpenseRepository _repository;

  GetJars(this._repository);

  Future<List<JarData>> call() async {
    return await _repository.getJars();
  }
}

