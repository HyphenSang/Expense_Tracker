import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction.dart' as domain;
import '../../domain/repositories/wallet.dart' as wallet_domain;
import '../../domain/repositories/jar.dart' as jar_domain;
import '../datasources/supabase.dart';
import '../models/transaction.dart';
import '../../core/supabase_flutter.dart';

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

    final transactionId = result['id'] as String;

    if (type == 'INCOME') {
      try {
        await _allocateIncomeToJars(
          userId: userId,
          transactionId: transactionId,
          incomeAmount: amount,
        );
      } catch (e) {}
    } else {
      // Nếu là CHI TIÊU: Trừ tiền từ hũ tương ứng với danh mục
      try {
        await _deductExpenseFromJar(
          userId: userId,
          transactionId: transactionId,
          categoryId: categoryId,
          expenseAmount: amount,
        );
      } catch (e) {}
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

    // Rollback jar_allocations thay vì redistribute để tránh ảnh hưởng đến các hũ khác
    try {
      await _rollbackJarAllocations(
        transactionId: transactionId,
        type: type,
      );
    } catch (e) {
      // Log lỗi nhưng không throw
    }

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
      // CHỈ cập nhật spent_amount, KHÔNG động đến limit_amount
      await _dataSource.updateBudget(
        budgetId: budgetId,
        data: {
          'spent_amount': spentAmount,
          // Đảm bảo KHÔNG cập nhật limit_amount
        },
      );

      // Tự động pause budget nếu strict mode và đã vượt 100%
      final budgetMode = budget['budget_mode'] as String?;
      if (budgetMode == 'strict' && spentAmount >= (budget['limit_amount'] as num? ?? 0)) {
        try {
          await _dataSource.updateBudget(
            budgetId: budgetId,
            data: {
              'is_paused': true,
            },
          );
        } catch (e) {
          // Bỏ qua nếu lỗi
        }
      }
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

        // Tự động pause budget nếu strict mode và đã vượt 100%
        final budgetMode = budget['budget_mode'] as String?;
        if (budgetMode == 'strict' && spentAmount >= (budget['limit_amount'] as num? ?? 0)) {
          try {
            await _dataSource.updateBudget(
              budgetId: budgetId,
              data: {
                'is_paused': true,
              },
            );
          } catch (e) {
            // Bỏ qua nếu lỗi
          }
        }
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

  Future<void> _allocateIncomeToJars({
    required String userId,
    required String transactionId,
    required num incomeAmount,
  }) async {
    final client = SupabaseConfig.client;

    await _jarRepository.ensureDefaultJars(userId);

    final jars = await _dataSource.getJars(userId);

    if (jars.isEmpty) {
      return;
    }

    final allocations = <Map<String, dynamic>>[];
    final jarUpdates = <String, num>{};

    for (final jar in jars) {
      final jarId = jar['id'] as String;
      final percentage = (jar['percentage'] as num?) ?? 0;
      final currentBalance = (jar['balance'] as num?) ?? 0;

      final allocatedAmount = (incomeAmount * percentage / 100).round();

      if (allocatedAmount > 0) {
        allocations.add({
          'jar_id': jarId,
          'transaction_id': transactionId,
          'amount': allocatedAmount,
        });

        jarUpdates[jarId] = currentBalance + allocatedAmount;
      }
    }

    if (allocations.isNotEmpty) {
      await client.from('jar_allocations').insert(allocations);
    }

    for (final entry in jarUpdates.entries) {
      await _jarRepository.updateJarBalance(
        jarId: entry.key,
        balance: entry.value.toDouble(),
      );
    }
  }

  /// Trừ tiền từ hũ tương ứng khi chi tiêu.
  /// Sử dụng category.jar_id nếu có, nếu không thì fallback về mapping dựa trên tên.
  Future<void> _deductExpenseFromJar({
    required String userId,
    required String transactionId,
    required String categoryId,
    required num expenseAmount,
  }) async {
    final client = SupabaseConfig.client;

    // Lấy thông tin category (bao gồm jar_id và name)
    final category = await client
        .from('categories')
        .select('jar_id, name')
        .eq('id', categoryId)
        .maybeSingle();

    if (category == null) return;

    // Lấy danh sách các hũ đang hoạt động
    final jars = await _dataSource.getJars(userId);

    if (jars.isEmpty) {
      return;
    }

    // Xác định hũ tương ứng
    String? targetJarId;

    // Ưu tiên 1: Sử dụng jar_id từ category nếu có
    final categoryJarId = category['jar_id'] as String?;
    if (categoryJarId != null) {
      // Kiểm tra jar có tồn tại và đang hoạt động không
      final jarExists = jars.any((jar) => jar['id'] == categoryJarId);
      if (jarExists) {
        targetJarId = categoryJarId;
      }
    }

    // Ưu tiên 2: Nếu không có jar_id, fallback về mapping dựa trên tên danh mục
    if (targetJarId == null) {
      final categoryName = (category['name'] as String?) ?? '';
      final categoryLower = categoryName.toLowerCase();

      String? targetJarSlug;
      if (categoryLower.contains('chợ') ||
          categoryLower.contains('siêu thị') ||
          categoryLower.contains('ăn uống') ||
          categoryLower.contains('ăn') ||
          categoryLower.contains('di chuyển') ||
          categoryLower.contains('xăng') ||
          categoryLower.contains('sức khỏe') ||
          categoryLower.contains('y tế')) {
        targetJarSlug = 'necessities';
      } else if (categoryLower.contains('giáo dục') ||
          categoryLower.contains('học') ||
          categoryLower.contains('sách')) {
        targetJarSlug = 'education';
      } else if (categoryLower.contains('mua sắm') ||
          categoryLower.contains('giải trí') ||
          categoryLower.contains('làm đẹp') ||
          categoryLower.contains('du lịch')) {
        targetJarSlug = 'play';
      } else if (categoryLower.contains('từ thiện') ||
          categoryLower.contains('cho đi') ||
          categoryLower.contains('quyên góp')) {
        targetJarSlug = 'give';
      }

      // Tìm hũ tương ứng theo slug
      if (targetJarSlug != null) {
        for (final jar in jars) {
          final slug = (jar['slug'] as String?) ?? '';
          if (slug == targetJarSlug) {
            targetJarId = jar['id'] as String;
            break;
          }
        }
      }
    }

    // Ưu tiên 3: Nếu vẫn không tìm thấy, mặc định trừ từ "Nhu cầu thiết yếu"
    if (targetJarId == null) {
      for (final jar in jars) {
        final slug = (jar['slug'] as String?) ?? '';
        if (slug == 'necessities' || slug.contains('nhu cầu')) {
          targetJarId = jar['id'] as String;
          break;
        }
      }
    }

    // Ưu tiên 4: Nếu vẫn không tìm thấy, lấy hũ đầu tiên
    if (targetJarId == null && jars.isNotEmpty) {
      targetJarId = jars[0]['id'] as String;
    }

    if (targetJarId == null) return;

    // Lấy số dư hiện tại của hũ
    final jar = jars.firstWhere(
      (j) => j['id'] == targetJarId,
      orElse: () => jars[0],
    );
    final currentBalance = (jar['balance'] as num?) ?? 0;

    // Tính số dư mới (trừ đi số tiền chi tiêu)
    final newBalance = (currentBalance - expenseAmount).clamp(0, double.infinity);

    // Cập nhật số dư hũ
    await _jarRepository.updateJarBalance(
      jarId: targetJarId,
      balance: newBalance.toDouble(),
    );

    // Lưu vào jar_allocations để theo dõi
    await client.from('jar_allocations').insert({
      'jar_id': targetJarId,
      'transaction_id': transactionId,
      'amount': expenseAmount,
    });
  }

  /// Rollback jar_allocations khi xóa transaction.
  /// Trừ tiền từ hũ nếu là INCOME, cộng lại nếu là EXPENSE.
  Future<void> _rollbackJarAllocations({
    required String transactionId,
    required String type,
  }) async {
    final client = SupabaseConfig.client;

    // Lấy tất cả jar_allocations của transaction này
    final allocations = await client
        .from('jar_allocations')
        .select('jar_id, amount')
        .eq('transaction_id', transactionId);

    if (allocations.isEmpty) return;

    // Rollback từng allocation
    for (final allocation in allocations) {
      final jarId = allocation['jar_id'] as String;
      final amount = (allocation['amount'] as num?) ?? 0;

      // Lấy số dư hiện tại của hũ
      final jar = await client
          .from('jars')
          .select('balance')
          .eq('id', jarId)
          .single();

      final currentBalance = (jar['balance'] as num?) ?? 0;

      // Tính số dư mới: nếu là INCOME thì trừ đi, nếu là EXPENSE thì cộng lại
      final newBalance = type == 'INCOME'
          ? (currentBalance - amount).clamp(0, double.infinity)
          : currentBalance + amount;

      // Cập nhật số dư hũ
      await _jarRepository.updateJarBalance(
        jarId: jarId,
        balance: newBalance.toDouble(),
      );
    }

    // Xóa jar_allocations
    await client
        .from('jar_allocations')
        .delete()
        .eq('transaction_id', transactionId);
  }
}

