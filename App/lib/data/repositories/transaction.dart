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

    // Cập nhật spent_amount của budgets nếu là chi tiêu
    if (type == 'EXPENSE') {
      try {
        // Cập nhật budget theo category
        await _updateBudgetSpentAmountByCategory(
          userId: userId,
          categoryId: categoryId,
          transactionDate: occurredAt,
        );

        // Cập nhật budget theo jar (nếu có jar_allocations)
        final transactionId = result['id'] as String;
        await _updateBudgetSpentAmountByJar(
          userId: userId,
          transactionId: transactionId,
          transactionDate: occurredAt,
        );
      } catch (e) {
        // Log lỗi nhưng không throw để không làm gián đoạn việc tạo transaction
      }
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

    // Cập nhật spent_amount của budgets nếu là chi tiêu đã xóa
    final categoryId = transactionData['category_id'] as String?;
    if (type == 'EXPENSE' && categoryId != null) {
      try {
        final occurredAtStr = transactionData['occurred_at'] as String?;
        if (occurredAtStr != null) {
          final occurredAt = DateTime.parse(occurredAtStr);
          // Cập nhật budget theo category
          await _updateBudgetSpentAmountByCategory(
            userId: user.id,
            categoryId: categoryId,
            transactionDate: occurredAt,
          );

          // Cập nhật budget theo jar (nếu có jar_allocations)
          final transactionId = transactionData['id'] as String;
          await _updateBudgetSpentAmountByJar(
            userId: user.id,
            transactionId: transactionId,
            transactionDate: occurredAt,
          );
        }
      } catch (e) {
        // Log lỗi nhưng không throw
      }
    }
  }

  /// Cập nhật spent_amount của budgets dựa trên category_id
  Future<void> _updateBudgetSpentAmountByCategory({
    required String userId,
    required String categoryId,
    required DateTime transactionDate,
  }) async {
    // Lấy tất cả budgets active của user có category_id này
    final budgets = await _dataSource.getBudgetsByCategory(
      userId: userId,
      categoryId: categoryId,
    );

    for (final budget in budgets) {
      final budgetId = budget['id'] as String;
      final startDate = DateTime.parse(budget['start_date'] as String);
      final endDateStr = budget['end_date'] as String?;
      final endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;
      final period = budget['period'] as String;

      // Kiểm tra transaction có nằm trong khoảng thời gian của budget không
      if (transactionDate.isBefore(startDate)) continue;
      if (endDate != null && transactionDate.isAfter(endDate)) continue;

      // Tính spent_amount dựa trên period và date range
      final spentAmount = await _calculateBudgetSpentAmount(
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        period: period,
        transactionDate: transactionDate,
      );

      // Cập nhật spent_amount trong database
      await _dataSource.updateBudget(
        budgetId: budgetId,
        data: {'spent_amount': spentAmount},
      );
    }
  }

  /// Tính spent_amount của budget dựa trên các transactions
  Future<num> _calculateBudgetSpentAmount({
    required String userId,
    required String categoryId,
    required DateTime startDate,
    DateTime? endDate,
    required String period,
    required DateTime transactionDate,
  }) async {
    // Tính date range dựa trên period và transaction date
    DateTime rangeStart;
    DateTime rangeEnd;

    switch (period) {
      case 'WEEKLY':
        // Tuần chứa transaction date (từ thứ 2 đến chủ nhật)
        final daysFromMonday = transactionDate.weekday - 1;
        rangeStart = transactionDate.subtract(Duration(days: daysFromMonday));
        rangeStart = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
        rangeEnd = rangeStart.add(const Duration(days: 7));
        break;
      case 'MONTHLY':
        // Tháng chứa transaction date
        rangeStart = DateTime(transactionDate.year, transactionDate.month, 1);
        rangeEnd = DateTime(transactionDate.year, transactionDate.month + 1, 1);
        break;
      case 'YEARLY':
        // Năm chứa transaction date
        rangeStart = DateTime(transactionDate.year, 1, 1);
        rangeEnd = DateTime(transactionDate.year + 1, 1, 1);
        break;
      default:
        rangeStart = startDate;
        rangeEnd = endDate ?? DateTime.now().add(const Duration(days: 365));
    }

    // Đảm bảo range không vượt quá budget date range
    if (rangeStart.isBefore(startDate)) rangeStart = startDate;
    if (endDate != null && rangeEnd.isAfter(endDate)) rangeEnd = endDate;

    // Lấy tất cả transactions EXPENSE trong khoảng thời gian này
    final transactions = await _dataSource.getTransactions(
      userId: userId,
      startDate: rangeStart,
      endDate: rangeEnd,
    );

    // Tính tổng chi tiêu cho category này
    num totalSpent = 0;
    for (final tx in transactions) {
      final txCategoryId = tx['category_id'] as String?;
      final txType = tx['type'] as String?;
      if (txCategoryId == categoryId && txType == 'EXPENSE') {
        totalSpent += (tx['amount'] as num?) ?? 0;
      }
    }

    return totalSpent;
  }

  /// Cập nhật spent_amount của budgets dựa trên jar_id từ jar_allocations
  Future<void> _updateBudgetSpentAmountByJar({
    required String userId,
    required String transactionId,
    required DateTime transactionDate,
  }) async {
    // Lấy jar_id từ jar_allocations
    final jarAllocations = await _dataSource.getJarAllocationsByTransaction(
      transactionId: transactionId,
    );

    for (final allocation in jarAllocations) {
      final jarId = allocation['jar_id'] as String?;
      if (jarId == null) continue;

      // Lấy tất cả budgets active của user có jar_id này
      final budgets = await _dataSource.getBudgetsByJar(
        userId: userId,
        jarId: jarId,
      );

      for (final budget in budgets) {
        final budgetId = budget['id'] as String;
        final startDate = DateTime.parse(budget['start_date'] as String);
        final endDateStr = budget['end_date'] as String?;
        final endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;
        final period = budget['period'] as String;

        // Kiểm tra transaction có nằm trong khoảng thời gian của budget không
        if (transactionDate.isBefore(startDate)) continue;
        if (endDate != null && transactionDate.isAfter(endDate)) continue;

        // Tính spent_amount dựa trên period và date range
        // Với jar, spent_amount là tổng amount từ jar_allocations trong khoảng thời gian
        final spentAmount = await _calculateBudgetSpentAmountByJar(
          userId: userId,
          jarId: jarId,
          startDate: startDate,
          endDate: endDate,
          period: period,
          transactionDate: transactionDate,
        );

        // Cập nhật spent_amount trong database
        await _dataSource.updateBudget(
          budgetId: budgetId,
          data: {'spent_amount': spentAmount},
        );
      }
    }
  }

  /// Tính spent_amount của budget theo jar dựa trên jar_allocations
  Future<num> _calculateBudgetSpentAmountByJar({
    required String userId,
    required String jarId,
    required DateTime startDate,
    DateTime? endDate,
    required String period,
    required DateTime transactionDate,
  }) async {
    // Tính date range dựa trên period và transaction date
    DateTime rangeStart;
    DateTime rangeEnd;

    switch (period) {
      case 'WEEKLY':
        final daysFromMonday = transactionDate.weekday - 1;
        rangeStart = transactionDate.subtract(Duration(days: daysFromMonday));
        rangeStart = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
        rangeEnd = rangeStart.add(const Duration(days: 7));
        break;
      case 'MONTHLY':
        rangeStart = DateTime(transactionDate.year, transactionDate.month, 1);
        rangeEnd = DateTime(transactionDate.year, transactionDate.month + 1, 1);
        break;
      case 'YEARLY':
        rangeStart = DateTime(transactionDate.year, 1, 1);
        rangeEnd = DateTime(transactionDate.year + 1, 1, 1);
        break;
      default:
        rangeStart = startDate;
        rangeEnd = endDate ?? DateTime.now().add(const Duration(days: 365));
    }

    // Đảm bảo range không vượt quá budget date range
    if (rangeStart.isBefore(startDate)) rangeStart = startDate;
    if (endDate != null && rangeEnd.isAfter(endDate)) rangeEnd = endDate;

    // Lấy tất cả jar_allocations của jar này trong khoảng thời gian
    final allocations = await _dataSource.getJarAllocationsByDateRange(
      jarId: jarId,
      startDate: rangeStart,
      endDate: rangeEnd,
    );

    // Tính tổng amount (chỉ lấy số dương vì đây là chi tiêu từ jar)
    num totalSpent = 0;
    for (final allocation in allocations) {
      final amount = (allocation['amount'] as num?) ?? 0;
      if (amount > 0) {
        totalSpent += amount;
      }
    }

    return totalSpent;
  }
}

