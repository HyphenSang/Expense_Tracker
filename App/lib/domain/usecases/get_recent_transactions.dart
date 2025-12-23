import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Use case để lấy danh sách giao dịch gần đây
class GetRecentTransactions {
  final TransactionRepository _repository;

  GetRecentTransactions(this._repository);

  Future<List<TransactionEntity>> call({int limit = 10}) async {
    return await _repository.getRecentTransactions(limit: limit);
  }
}

