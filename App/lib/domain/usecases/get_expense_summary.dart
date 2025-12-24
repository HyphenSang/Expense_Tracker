import '../repositories/expense.dart';

/// Use case để lấy tóm tắt số liệu tài chính
class GetExpenseSummary {
  final ExpenseRepository _repository;

  GetExpenseSummary(this._repository);

  Future<ExpenseSummary> call() async {
    return await _repository.getSummary();
  }

  Future<ExpenseSummary> forMonth({
    required int year,
    required int month,
  }) async {
    return await _repository.getSummaryForMonth(
      year: year,
      month: month,
    );
  }
}
