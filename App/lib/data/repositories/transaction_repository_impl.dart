import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/supabase_datasource.dart';
import '../models/transaction_model.dart';

/// Implementation của TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseDataSource _dataSource;

  TransactionRepositoryImpl(this._dataSource);

  @override
  Future<List<TransactionEntity>> getRecentTransactions({
    int limit = 10,
  }) async {
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) {
      throw StateError('Chưa đăng nhập');
    }

    final now = DateTime.now();
    final data = await _dataSource.getTransactions(
      userId: user.id,
      endDate: now,
      limit: limit,
    );

    return data.map((json) => TransactionModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByMonth({
    required int year,
    required int month,
    int limit = 1000,
  }) async {
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) {
      throw StateError('Chưa đăng nhập');
    }

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final data = await _dataSource.getTransactions(
      userId: user.id,
      startDate: start,
      endDate: end,
      limit: limit,
    );

    return data.map((json) => TransactionModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<TransactionEntity> createTransaction({
    required String userId,
    required String walletId,
    required String categoryId,
    required String type,
    required num amount,
    required String note,
    required DateTime occurredAt,
  }) async {
    final data = {
      'user_id': userId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
    };

    final result = await _dataSource.createTransaction(data);
    return TransactionModel.fromJson(result).toEntity();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _dataSource.deleteTransaction(transactionId);
  }
}

