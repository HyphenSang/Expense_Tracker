import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget.dart' as domain;
import '../datasources/supabase.dart';
import '../models/budget.dart';

/// Implementation của BudgetRepository
class BudgetRepositoryImpl implements domain.BudgetRepository {
  final SupabaseDataSource _dataSource;

  BudgetRepositoryImpl(this._dataSource);

  @override
  Future<List<BudgetEntity>> getBudgets(String userId) async {
    final budgets = await _dataSource.getBudgets(userId);
    return budgets.map((json) => BudgetModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<BudgetEntity> createBudget({
    required String userId,
    String? categoryId,
    String? jarId,
    required String period,
    required num limitAmount,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) async {
    final data = {
      'user_id': userId,
      'category_id': categoryId,
      'jar_id': jarId,
      'period': period,
      'limit_amount': limitAmount,
      'spent_amount': 0,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_active': isActive,
    };

    final result = await _dataSource.createBudget(data);
    return BudgetModel.fromJson(result).toEntity();
  }

  @override
  Future<BudgetEntity> updateBudget(String budgetId, Map<String, dynamic> data) async {
    await _dataSource.updateBudget(budgetId: budgetId, data: data);
    // Lấy lại budget sau khi update - cần userId từ budget hiện tại
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) {
      throw StateError('Chưa đăng nhập');
    }
    final budgets = await _dataSource.getBudgets(user.id);
    final updated = budgets.firstWhere((b) => b['id'] == budgetId);
    return BudgetModel.fromJson(updated).toEntity();
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    await _dataSource.deleteBudget(budgetId);
  }

  @override
  Future<num> calculateSpentAmount({
    required String userId,
    String? categoryId,
    String? jarId,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    // Logic tính spent_amount đã được implement trong TransactionRepository
    // Nên method này có thể để trống hoặc delegate
    // Tạm thời return 0, logic thực tế đã được xử lý trong TransactionRepository
    return 0;
  }
}

