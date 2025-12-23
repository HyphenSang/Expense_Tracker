import '../entities/transaction_entity.dart';

/// Repository interface cho Transaction trong domain layer
abstract class TransactionRepository {
  /// Lấy danh sách giao dịch gần đây
  Future<List<TransactionEntity>> getRecentTransactions({
    int limit = 10,
  });

  /// Lấy giao dịch theo tháng/năm
  Future<List<TransactionEntity>> getTransactionsByMonth({
    required int year,
    required int month,
    int limit = 1000,
  });

  /// Tạo giao dịch mới
  Future<TransactionEntity> createTransaction({
    required String userId,
    required String walletId,
    required String categoryId,
    required String type,
    required num amount,
    required String note,
    required DateTime occurredAt,
  });

  /// Xóa giao dịch
  Future<void> deleteTransaction(String transactionId);
}

