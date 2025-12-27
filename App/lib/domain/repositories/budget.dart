import '../entities/budget.dart';

/// Repository interface cho Budget trong domain layer
abstract class BudgetRepository {
  /// Lấy danh sách budgets của user
  Future<List<BudgetEntity>> getBudgets(String userId);

  /// Tạo budget mới
  Future<BudgetEntity> createBudget({
    required String userId,
    String? categoryId,
    String? jarId,
    required String period,
    required num limitAmount,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive,
  });

  /// Cập nhật budget
  Future<BudgetEntity> updateBudget(String budgetId, Map<String, dynamic> data);

  /// Xóa budget
  Future<void> deleteBudget(String budgetId);

  /// Tính spent_amount dựa trên transactions
  Future<num> calculateSpentAmount({
    required String userId,
    String? categoryId,
    String? jarId,
    required DateTime startDate,
    DateTime? endDate,
  });
}

