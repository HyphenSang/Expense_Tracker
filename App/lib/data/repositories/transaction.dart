import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction.dart' as domain;
import '../../domain/repositories/wallet.dart' as wallet_domain;
import '../../domain/repositories/jar.dart' as jar_domain;
import '../datasources/supabase.dart';
import '../models/transaction.dart';

/// Implementation của TransactionRepository
class TransactionRepositoryImpl implements domain.TransactionRepository {
  final SupabaseDataSource _dataSource;
  final wallet_domain.WalletRepository _walletRepository;
  final jar_domain.JarRepository _jarRepository;

  TransactionRepositoryImpl(
    this._dataSource,
    this._walletRepository,
    this._jarRepository,
  );

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
    // Lấy wallet để đọc balance hiện tại
    final wallets = await _walletRepository.getWallets(userId);
    final wallet = wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => throw StateError('Wallet không tồn tại hoặc không thuộc về user này'),
    );

    // Tính balance mới
    final currentBalance = wallet.balance;
    final newBalance = type == 'EXPENSE'
        ? currentBalance - amount  // Chi tiêu: trừ đi
        : currentBalance + amount;  // Thu nhập: cộng vào

    // Tạo transaction
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
    
    // Cập nhật balance của wallet SAU KHI tạo transaction thành công
    await _walletRepository.updateWalletBalance(
      walletId: walletId,
      balance: newBalance,
    );

    // Chia lại các hũ theo % dựa trên total balance mới
    try {
      await _jarRepository.redistributeJarsByTotalBalance(userId);
    } catch (e) {
      // Log lỗi nhưng không throw để không làm gián đoạn việc tạo transaction
      // Lỗi được xử lý im lặng để không ảnh hưởng đến flow chính
    }

    return TransactionModel.fromJson(result).toEntity();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    // Lấy thông tin transaction trước khi xóa
    final transactionData = await _dataSource.getTransactionById(transactionId);
    if (transactionData == null) {
      throw StateError('Transaction không tồn tại');
    }

    final walletId = transactionData['wallet_id'] as String;
    final type = transactionData['type'] as String;
    final amount = (transactionData['amount'] as num);

    // Lấy wallet để đọc balance hiện tại
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) {
      throw StateError('Chưa đăng nhập');
    }

    final wallets = await _walletRepository.getWallets(user.id);
    final wallet = wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => throw StateError('Wallet không tồn tại hoặc không thuộc về user này'),
    );

    // Tính balance mới (rollback): nếu là EXPENSE thì cộng lại, nếu là INCOME thì trừ đi
    final currentBalance = wallet.balance;
    final newBalance = type == 'EXPENSE'
        ? currentBalance + amount  // Chi tiêu đã xóa: cộng lại
        : currentBalance - amount; // Thu nhập đã xóa: trừ đi

    // Xóa transaction
    await _dataSource.deleteTransaction(transactionId);

    // Cập nhật balance của wallet SAU KHI xóa transaction thành công
    await _walletRepository.updateWalletBalance(
      walletId: walletId,
      balance: newBalance,
    );

    // Chia lại các hũ theo % dựa trên total balance mới
    await _jarRepository.redistributeJarsByTotalBalance(user.id);
  }
}

