import '../../domain/repositories/expense.dart' as domain_expense;
import '../datasources/supabase.dart';
import '../../core/supabase_flutter.dart';
import '../../common/theme.dart';
import '../../presentation/widgets/recent_transactions.dart';
import '../../presentation/widgets/jar_data.dart';
import '../../service/expense.dart' hide MonthlyComparison, ExpenseSummary, CategorySpendingSummary;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Implementation của ExpenseRepository
class ExpenseRepositoryImpl implements domain_expense.ExpenseRepository {
  static SupabaseClient get _client => SupabaseConfig.client;

  ExpenseRepositoryImpl(SupabaseDataSource dataSource) {
    // dataSource được truyền vào để đảm bảo tính nhất quán với các repository khác
    // nhưng hiện tại không được sử dụng vì code đang dùng _client trực tiếp
  }

  static User? get _currentUser => _client.auth.currentUser;

  static String _formatCurrency(num value) {
    final intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final reversedIndex = str.length - i - 1;
      buffer.write(str[i]);
      final isThousand = reversedIndex % 3 == 0 && i != str.length - 1;
      if (isThousand) buffer.write('.');
    }
    return '${buffer.toString()} ₫';
  }

  @override
  Future<domain_expense.ExpenseSummary> getSummary() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu tài chính.');
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final walletsRes = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', user.id)
        .eq('is_active', true);

    num totalBalance = 0;
    for (final row in walletsRes) {
      totalBalance += (row['balance'] as num?) ?? 0;
    }

    final txRes = await _client
        .from('transactions')
        .select('type, amount, occurred_at')
        .eq('user_id', user.id)
        .gte('occurred_at', monthStart.toIso8601String());

    num income = 0;
    num expense = 0;

    for (final row in txRes) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      if (type == 'INCOME') {
        income += amount;
      } else if (type == 'EXPENSE') {
        expense += amount;
      }
    }

    final saved = income - expense;

    return domain_expense.ExpenseSummary(
      totalBalance: _formatCurrency(totalBalance),
      monthlyIncome: _formatCurrency(income),
      monthlyExpense: _formatCurrency(expense),
      monthlySaved: _formatCurrency(saved),
    );
  }

  @override
  Future<domain_expense.ExpenseSummary> getSummaryForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu tài chính.');
    }

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 1);

    final walletsRes = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', user.id)
        .eq('is_active', true);

    num totalBalance = 0;
    for (final row in walletsRes) {
      totalBalance += (row['balance'] as num?) ?? 0;
    }

    final txRes = await _client
        .from('transactions')
        .select('type, amount, occurred_at')
        .eq('user_id', user.id)
        .gte('occurred_at', monthStart.toIso8601String())
        .lt('occurred_at', monthEnd.toIso8601String());

    num income = 0;
    num expense = 0;

    for (final row in txRes) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      if (type == 'INCOME') {
        income += amount;
      } else if (type == 'EXPENSE') {
        expense += amount;
      }
    }

    final saved = income - expense;

    return domain_expense.ExpenseSummary(
      totalBalance: _formatCurrency(totalBalance),
      monthlyIncome: _formatCurrency(income),
      monthlyExpense: _formatCurrency(expense),
      monthlySaved: _formatCurrency(saved),
    );
  }

  @override
  Future<Map<String, num>> getIncomeExpenseForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return {'income': 0, 'expense': 0};
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final income = await _sumAmountInRange(
      userId: user.id,
      start: start,
      end: end,
      type: 'INCOME',
    );
    final expense = await _sumAmountInRange(
      userId: user.id,
      start: start,
      end: end,
      type: 'EXPENSE',
    );

    return {'income': income, 'expense': expense};
  }

  @override
  Future<domain_expense.MonthlyComparison> getMonthComparison({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải dữ liệu so sánh tháng.');
    }

    final currentStart = DateTime(year, month, 1);
    final currentEnd = DateTime(year, month + 1, 1);

    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final previousStart = DateTime(prevYear, prevMonth, 1);
    final previousEnd = currentStart;

    final userId = user.id;

    final prevIncome = await _sumAmountInRange(
      userId: userId,
      start: previousStart,
      end: previousEnd,
      type: 'INCOME',
    );
    final prevExpense = await _sumAmountInRange(
      userId: userId,
      start: previousStart,
      end: previousEnd,
      type: 'EXPENSE',
    );

    final currIncome = await _sumAmountInRange(
      userId: userId,
      start: currentStart,
      end: currentEnd,
      type: 'INCOME',
    );
    final currExpense = await _sumAmountInRange(
      userId: userId,
      start: currentStart,
      end: currentEnd,
      type: 'EXPENSE',
    );

    String monthLabel(int m) => 'Tháng $m';

    return domain_expense.MonthlyComparison(
      previousMonthLabel: monthLabel(previousStart.month),
      currentMonthLabel: monthLabel(currentStart.month),
      previousIncome: _formatCurrency(prevIncome),
      previousExpense: _formatCurrency(prevExpense),
      currentIncome: _formatCurrency(currIncome),
      currentExpense: _formatCurrency(currExpense),
    );
  }

  @override
  Future<List<domain_expense.CategorySpendingSummary>> getCategorySpendingForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return const [];
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    // Bước 1: Query categories của user trước để đảm bảo chỉ lấy categories của user hiện tại
    final userCategoriesRes = await _client
        .from('categories')
        .select('id, name, icon, color')
        .eq('user_id', user.id) // Chỉ lấy categories của user hiện tại
        .eq('type', 'EXPENSE');
    
    // Tạo map category_id -> category info để validate và lấy icon/color
    final Map<String, Map<String, dynamic>> categoryMap = {};
    for (final cat in userCategoriesRes) {
      final catId = cat['id'] as String?;
      if (catId != null) {
        categoryMap[catId] = {
          'name': cat['name'] as String? ?? 'Chưa phân loại',
          'icon': cat['icon'] as String?,
          'color': cat['color'] as String?,
        };
      }
    }

    // Bước 2: Query transactions với category_id (không join categories)
    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at, category_id')
        .eq('user_id', user.id) // Filter transactions theo user_id
        .eq('type', 'EXPENSE') // Chỉ lấy chi tiêu
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    final Map<String, num> byCategory = {};
    final Map<String, Map<String, dynamic>> categoryInfo = {}; // Lưu icon và color theo tên category

    for (final row in res) {
      final categoryId = row['category_id'] as String?;
      
      // Chỉ xử lý nếu category_id thuộc về user hiện tại
      final catData = categoryId != null ? categoryMap[categoryId] : null;
      if (catData == null) {
        continue;
      }
      
      final catName = catData['name'] as String? ?? 'Chưa phân loại';
      final amount = (row['amount'] as num?) ?? 0;
      
      // Chỉ thêm vào byCategory nếu amount > 0
      if (amount > 0) {
        byCategory[catName] = (byCategory[catName] ?? 0) + amount;
      }
      
      // Lưu icon và color từ database (nếu có)
      if (!categoryInfo.containsKey(catName)) {
        categoryInfo[catName] = {
          'icon': catData['icon'] as String?,
          'color': catData['color'] as String?,
        };
      }
    }

    final total = byCategory.values.fold<num>(0, (p, e) => p + e);

    if (total <= 0) {
      return const [];
    }

    final defaultCategoryMap = _getDefaultCategoryMap();

    // Chỉ xử lý categories đã được validate là của user (đã có trong byCategory sau khi filter)
    final list = byCategory.entries
        .where((e) => e.value > 0) // Chỉ hiển thị categories có amount > 0
        .map(
          (e) {
            final catName = e.key;
            final catNameLower = catName.toLowerCase();
            
            // Ưu tiên lấy icon/color từ default categories (để đảm bảo icon/color đúng)
            // Nếu không có trong default, mới lấy từ database
            IconData icon;
            Color color;
            
            final defaultInfo = defaultCategoryMap[catNameLower];
            if (defaultInfo != null) {
              // Có trong default categories - dùng icon/color từ default
              icon = defaultInfo['icon'] as IconData;
              color = defaultInfo['color'] as Color;
            } else {
              // Không có trong default - thử lấy từ database
              final dbInfo = categoryInfo[catName];
              if (dbInfo != null && dbInfo['icon'] != null && dbInfo['color'] != null) {
                // Lấy từ database
                final iconStr = dbInfo['icon'] as String?;
                final colorStr = dbInfo['color'] as String?;
                
                // Kiểm tra icon có phải là codePoint hợp lệ không
                icon = _getIconFromString(iconStr);
                
                try {
                  if (colorStr != null && colorStr.isNotEmpty) {
                    color = Color(
                      int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000,
                    );
                  } else {
                    color = AppColors.gray500;
                  }
                } catch (_) {
                  color = AppColors.gray500;
                }
              } else {
                // Fallback cuối cùng
                icon = Icons.category;
                color = AppColors.gray500;
              }
            }
            
            return domain_expense.CategorySpendingSummary(
              name: catName,
              amount: e.value,
              percentage: (e.value * 100.0) / total,
              icon: icon,
              color: color,
            );
          },
        )
        .toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  @override
  Future<List<domain_expense.CategorySpendingSummary>> getCategoryIncomeForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return const [];
    }

    final start = DateTime(year, month, 1);
    final end = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    // Bước 1: Query categories của user trước để đảm bảo chỉ lấy categories của user hiện tại
    final userCategoriesRes = await _client
        .from('categories')
        .select('id, name, icon, color')
        .eq('user_id', user.id) // Chỉ lấy categories của user hiện tại
        .eq('type', 'INCOME');
    
    // Tạo map category_id -> category info để validate và lấy icon/color
    final Map<String, Map<String, dynamic>> categoryMap = {};
    for (final cat in userCategoriesRes) {
      final catId = cat['id'] as String?;
      if (catId != null) {
        categoryMap[catId] = {
          'name': cat['name'] as String? ?? 'Chưa phân loại',
          'icon': cat['icon'] as String?,
          'color': cat['color'] as String?,
        };
      }
    }

    // Bước 2: Query transactions với category_id (không join categories)
    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at, category_id')
        .eq('user_id', user.id) // Filter transactions theo user_id
        .eq('type', 'INCOME') // Chỉ lấy thu nhập
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    final Map<String, num> byCategory = {};
    final Map<String, Map<String, dynamic>> categoryInfo = {}; // Lưu icon và color theo tên category

    for (final row in res) {
      final categoryId = row['category_id'] as String?;
      
      // Chỉ xử lý nếu category_id thuộc về user hiện tại
      final catData = categoryId != null ? categoryMap[categoryId] : null;
      if (catData == null) {
        // Category không thuộc về user này - bỏ qua
        continue;
      }
      
      final catName = catData['name'] as String? ?? 'Chưa phân loại';
      final amount = (row['amount'] as num?) ?? 0;
      
      // Chỉ thêm vào byCategory nếu amount > 0
      if (amount > 0) {
        byCategory[catName] = (byCategory[catName] ?? 0) + amount;
      }
      
      // Lưu icon và color từ database (nếu có)
      if (!categoryInfo.containsKey(catName)) {
        categoryInfo[catName] = {
          'icon': catData['icon'] as String?,
          'color': catData['color'] as String?,
        };
      }
    }

    final total = byCategory.values.fold<num>(0, (p, e) => p + e);

    if (total <= 0) {
      return const [];
    }

    final defaultCategoryMap = _getDefaultIncomeCategoryMap();

    // Chỉ xử lý categories đã được validate là của user (đã có trong byCategory sau khi filter)
    final list = byCategory.entries
        .where((e) => e.value > 0) // Chỉ hiển thị categories có amount > 0
        .map(
          (e) {
            final catName = e.key;
            final catNameLower = catName.toLowerCase();
            
            // Ưu tiên lấy icon/color từ default categories (để đảm bảo icon/color đúng)
            // Nếu không có trong default, mới lấy từ database
            IconData icon;
            Color color;
            
            final defaultInfo = defaultCategoryMap[catNameLower];
            if (defaultInfo != null) {
              // Có trong default categories - dùng icon/color từ default
              icon = defaultInfo['icon'] as IconData;
              color = defaultInfo['color'] as Color;
            } else {
              // Không có trong default - thử lấy từ database
              final dbInfo = categoryInfo[catName];
              if (dbInfo != null && dbInfo['icon'] != null && dbInfo['color'] != null) {
                // Lấy từ database
                final iconStr = dbInfo['icon'] as String?;
                final colorStr = dbInfo['color'] as String?;
                
                // Kiểm tra icon có phải là codePoint hợp lệ không
                icon = _getIconFromString(iconStr);
                
                try {
                  if (colorStr != null && colorStr.isNotEmpty) {
                    color = Color(
                      int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000,
                    );
                  } else {
                    color = AppColors.success;
                  }
                } catch (_) {
                  color = AppColors.success;
                }
              } else {
                // Fallback cuối cùng
                icon = Icons.category;
                color = AppColors.success;
              }
            }
            
            return domain_expense.CategorySpendingSummary(
              name: catName,
              amount: e.value,
              percentage: (e.value * 100.0) / total,
              icon: icon,
              color: color,
            );
          },
        )
        .toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  @override
  Future<List<SpendingTrendItem>> getSpendingTrendsForMonth({
    required int year,
    required int month,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải xu hướng chi tiêu.');
    }

    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;

    final selectedMonthStart = DateTime(year, month, 1);
    final selectedMonthEnd = DateTime(year, month + 1, 1);

    final prevMonthStart = DateTime(prevYear, prevMonth, 1);
    final prevMonthEnd = selectedMonthStart;

    final selectedYearStart = DateTime(year, 1, 1);
    final selectedYearEnd = DateTime(year + 1, 1, 1);

    final prevYearStart = DateTime(year - 1, 1, 1);
    final prevYearEnd = selectedYearStart;

    final now = DateTime(year, month, 15);
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 7));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    final userId = user.id;

    Future<num> sumExpense(DateTime s, DateTime e) => _sumAmountInRange(
          userId: userId,
          start: s,
          end: e,
          type: 'EXPENSE',
        );

    final thisWeek = await sumExpense(thisWeekStart, thisWeekEnd);
    final lastWeek = await sumExpense(lastWeekStart, lastWeekEnd);

    final thisMonth = await sumExpense(selectedMonthStart, selectedMonthEnd);
    final lastMonth = await sumExpense(prevMonthStart, prevMonthEnd);

    final thisYear = await sumExpense(selectedYearStart, selectedYearEnd);
    final lastYear = await sumExpense(prevYearStart, prevYearEnd);

    String pct(num current, num previous) {
      if (previous <= 0) return '0%';
      final p = ((current - previous) / previous * 100).abs();
      return '${p.toStringAsFixed(1)}%';
    }

    bool isIncrease(num current, num previous) => current > previous;

    return [
      SpendingTrendItem(
        label: 'Tuần này',
        amount: _formatCurrency(thisWeek),
        changePercent: pct(thisWeek, lastWeek),
        isIncrease: isIncrease(thisWeek, lastWeek),
      ),
      SpendingTrendItem(
        label: 'Tháng này',
        amount: _formatCurrency(thisMonth),
        changePercent: pct(thisMonth, lastMonth),
        isIncrease: isIncrease(thisMonth, lastMonth),
      ),
      SpendingTrendItem(
        label: 'Năm này',
        amount: _formatCurrency(thisYear),
        changePercent: pct(thisYear, lastYear),
        isIncrease: isIncrease(thisYear, lastYear),
      ),
    ];
  }

  @override
  Future<List<TransactionItemData>?> getRecentTransactions({
    int limit = 10,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải giao dịch.');
    }

    final res = await _client
        .from('transactions')
        .select('id, type, amount, note, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false)
        .limit(limit);

    final list = <TransactionItemData>[];

    for (final row in res as List) {
      final id = row['id'] as String?;
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      final note = (row['note'] as String?) ?? 'Giao dịch';
      final occurredAtStr = row['occurred_at'] as String?;
      DateTime? occurredAt;
      if (occurredAtStr != null) {
        try {
          final parsed = DateTime.parse(occurredAtStr);
          if (parsed.isUtc) {
            occurredAt = parsed;
          } else if (occurredAtStr.endsWith('+00') || occurredAtStr.endsWith('Z')) {
            occurredAt = DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          } else {
            occurredAt = parsed.isUtc ? parsed : DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          }
        } catch (e) {
          occurredAt = DateTime.tryParse(occurredAtStr);
        }
      }

      final isIncome = type == 'INCOME';
      final categoryName = (row['categories'] as Map?)?['name'] as String? ?? (isIncome ? 'Thu nhập' : 'Chi tiêu');
      final color = isIncome ? AppColors.success : AppColors.error;
      final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

      String timeLabel = '';
      String dateLabel = '';
      if (occurredAt != null) {
        timeLabel = '${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
        dateLabel = '${occurredAt.day}/${occurredAt.month}/${occurredAt.year}';
      }

      list.add(
        TransactionItemData(
          id: id,
          title: note,
          category: categoryName,
          amount: '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
          icon: icon,
          color: color,
          time: '$timeLabel - $dateLabel',
          occurredAt: occurredAt,
        ),
      );
    }

    if (list.isEmpty) {
      return [];
    }

    return list;
  }

  @override
  Future<List<TransactionItemData>?> getTransactionsByMonth({
    required int year,
    required int month,
    int limit = 1000,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải giao dịch.');
    }

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final res = await _client
        .from('transactions')
        .select('type, amount, note, occurred_at, categories(name)')
        .eq('user_id', user.id)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String())
        .order('occurred_at', ascending: false)
        .limit(limit);

    final list = <TransactionItemData>[];

    for (final row in res as List) {
      final type = row['type'] as String?;
      final amount = (row['amount'] as num?) ?? 0;
      final note = (row['note'] as String?) ?? 'Giao dịch';
      final occurredAtStr = row['occurred_at'] as String?;
      DateTime? occurredAt;
      if (occurredAtStr != null) {
        try {
          final parsed = DateTime.parse(occurredAtStr);
          if (parsed.isUtc) {
            occurredAt = parsed;
          } else if (occurredAtStr.endsWith('+00') || occurredAtStr.endsWith('Z')) {
            occurredAt = DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          } else {
            occurredAt = parsed.isUtc ? parsed : DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
            );
          }
        } catch (e) {
          occurredAt = DateTime.tryParse(occurredAtStr);
        }
      }

      final isIncome = type == 'INCOME';
      final categoryName = (row['categories'] as Map?)?['name'] as String? ??
          (isIncome ? 'Thu nhập' : 'Chi tiêu');
      final color = isIncome ? AppColors.success : AppColors.error;
      final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

      String timeLabel = '';
      String dateLabel = '';
      if (occurredAt != null) {
        timeLabel = '${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
        dateLabel = '${occurredAt.day}/${occurredAt.month}/${occurredAt.year}';
      }

      list.add(
        TransactionItemData(
          title: note,
          category: categoryName,
          amount: '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
          icon: icon,
          color: color,
          time: '$timeLabel - $dateLabel',
          occurredAt: occurredAt,
        ),
      );
    }

    return list;
  }

  @override
  Future<List<WalletInfo>> getWallets() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải ví.');
    }

    final res = await _client
        .from('wallets')
        .select('name, type, balance, bank_name, is_active')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    final list = <WalletInfo>[];

    for (final row in res) {
      final name = (row['name'] as String?) ?? 'Ví không tên';
      final type = (row['type'] as String?) ?? 'Unknown';
      final balance = (row['balance'] as num?) ?? 0;
      final bankName = row['bank_name'] as String?;
      list.add(
        WalletInfo(
          name: name,
          type: type,
          balanceFormatted: _formatCurrency(balance),
          bankName: bankName,
        ),
      );
    }

    return list;
  }

  /// Lấy tất cả ví (bao gồm cả không hoạt động) để quản lý
  Future<List<Map<String, dynamic>>> getAllWalletsForManagement() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải ví.');
    }

    final res = await _client
        .from('wallets')
        .select('id, name, type, balance, bank_name, is_active')
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Future<List<JarData>> getJars() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải 6 hũ tài chính.');
    }

    final res = await _client
        .from('jars')
        .select('name, balance, percentage')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    final list = <JarData>[];
    final colors = <Color>[
      AppColors.error,
      AppColors.info,
      AppColors.warning,
      AppColors.primary,
      AppColors.success,
      AppColors.secondary,
    ];

    for (var i = 0; i < res.length; i++) {
      final row = res[i];
      final name = (row['name'] as String?) ?? 'Jar';
      final percentage = (row['percentage'] as int?) ?? 0;
      final balance = (row['balance'] as num?) ?? 0;
      final color = colors[i % colors.length];

      list.add(
        JarData(
          name: name,
          amount: _formatCurrency(balance),
          percentage: '$percentage%',
          icon: Icons.savings,
          color: color,
          progress: (percentage / 100).clamp(0.0, 1.0),
        ),
      );
    }

    if (list.isEmpty) {
      return [];
    }

    return list;
  }

  Future<num> _sumAmountInRange({
    required String userId,
    required DateTime start,
    required DateTime end,
    required String type,
  }) async {
    final res = await _client
        .from('transactions')
        .select('amount, type, occurred_at')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());

    num total = 0;
    for (final row in res as List) {
      total += (row['amount'] as num?) ?? 0;
    }
    return total;
  }

  Map<String, Map<String, dynamic>> _getDefaultCategoryMap() {
    return {
      'chợ, siêu thị': {
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'ăn uống': {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFFFEB3B),
      },
      'di chuyển': {
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF81D4FA),
      },
      'mua sắm': {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFF48FB1),
      },
      'giải trí': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'làm đẹp': {
        'icon': Icons.brush_outlined,
        'color': const Color(0xFFE91E63),
      },
      'sức khỏe': {
        'icon': Icons.favorite_outlined,
        'color': const Color(0xFFFF5252),
      },
      'từ thiện': {
        'icon': Icons.volunteer_activism_outlined,
        'color': const Color(0xFFFFAB91),
      },
      'hóa đơn': {
        'icon': Icons.receipt_long_outlined,
        'color': const Color(0xFF10B981),
      },
      'nhà cửa': {
        'icon': Icons.home_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      'người thân': {
        'icon': Icons.people_outline,
        'color': const Color(0xFFF48FB1),
      },
      'học tập': {
        'icon': Icons.school_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      'đầu tư': {
        'icon': Icons.trending_up_outlined,
        'color': const Color(0xFF10B981),
      },
    };
  }

  Map<String, Map<String, dynamic>> _getDefaultIncomeCategoryMap() {
    return {
      'lương': {
        'icon': Icons.work_outline,
        'color': const Color(0xFF66BB6A),
      },
      'thưởng': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFF29B6F6),
      },
      'thu nhập phụ': {
        'icon': Icons.trending_up_outlined,
        'color': const Color(0xFF26A69A),
      },
      'khác': {
        'icon': Icons.more_horiz,
        'color': AppColors.gray500,
      },
    };
  }

  /// Parse icon string từ database thành IconData
  IconData _getIconFromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    
    // Parse format: "codePoint" hoặc "codePoint:fontFamily"
    try {
      if (iconName.contains(':')) {
        final parts = iconName.split(':');
        final codePoint = int.parse(parts[0]);
        final fontFamily = parts[1];
        return IconData(
          codePoint,
          fontFamily: fontFamily,
        );
      } else {
        // Chỉ có codePoint, dùng MaterialIcons mặc định
        final codePoint = int.parse(iconName);
        return IconData(
          codePoint,
          fontFamily: 'MaterialIcons',
        );
      }
    } catch (e) {
      // Nếu parse lỗi, trả về icon mặc định
      return Icons.category;
    }
  }
}

