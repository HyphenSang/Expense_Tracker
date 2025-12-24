import '../repositories/transaction.dart';
import '../entities/transaction.dart';

/// Use case để tạo giao dịch mới
class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  Future<TransactionEntity> call({
    required String userId,
    required String walletId,
    required String categoryId,
    required String type,
    required num amount,
    required String note,
    required DateTime occurredAt,
  }) async {
    return await _repository.createTransaction(
      userId: userId,
      walletId: walletId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      note: note,
      occurredAt: occurredAt,
    );
  }
}

/// Use case để lấy danh sách giao dịch gần đây
class GetRecentTransactions {
  final TransactionRepository _repository;

  GetRecentTransactions(this._repository);

  Future<List<TransactionEntity>> call({int limit = 10}) async {
    return await _repository.getRecentTransactions(limit: limit);
  }
}

