import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service gợi ý điều chỉnh ngân sách
class BudgetSuggestionService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Gợi ý điều chỉnh ngân sách dựa trên lịch sử
  static Future<BudgetSuggestion> suggestBudgetAdjustment({
    required String userId,
    required String budgetId,
    required String categoryId,
    required num currentLimit,
    int monthsBack = 3,
  }) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - monthsBack, 1);
    
    // Lấy tất cả transactions của category này trong 3 tháng gần nhất
    final transactions = await _client
        .from('transactions')
        .select('amount, occurred_at')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('type', 'EXPENSE')
        .gte('occurred_at', startDate.toIso8601String());

    // Tính trung bình chi tiêu mỗi tháng
    final Map<int, num> spendingByMonth = {};
    
    for (final tx in transactions) {
      final occurredAt = DateTime.parse(tx['occurred_at'] as String);
      final monthKey = occurredAt.year * 100 + occurredAt.month;
      final amount = (tx['amount'] as num?) ?? 0;
      spendingByMonth[monthKey] = (spendingByMonth[monthKey] ?? 0) + amount;
    }

    if (spendingByMonth.isEmpty) {
      return BudgetSuggestion(
        suggestedLimit: currentLimit.toDouble(),
        reason: 'Chưa có đủ dữ liệu để đưa ra gợi ý',
        confidence: 0,
      );
    }

    // Tính trung bình
    final averageMonthlySpending = spendingByMonth.values.fold<num>(0, (sum, amount) => sum + amount) 
        / spendingByMonth.length;
    
    // Gợi ý: trung bình + 10% buffer
    final suggestedLimit = (averageMonthlySpending * 1.1).round();
    
    // Tính độ tin cậy dựa trên số tháng có dữ liệu
    final confidence = (spendingByMonth.length / monthsBack).clamp(0.0, 1.0).toDouble();
    
    String reason;
    if (suggestedLimit > currentLimit * 1.2) {
      reason = 'Bạn thường chi tiêu ${_formatCurrency(averageMonthlySpending)}/tháng, '
          'nhưng ngân sách hiện tại chỉ ${_formatCurrency(currentLimit)}. '
          'Bạn có muốn tăng ngân sách lên ${_formatCurrency(suggestedLimit)} không?';
    } else if (suggestedLimit < currentLimit * 0.8) {
      reason = 'Bạn thường chi tiêu ${_formatCurrency(averageMonthlySpending)}/tháng, '
          'nhưng ngân sách hiện tại là ${_formatCurrency(currentLimit)}. '
          'Bạn có thể giảm ngân sách xuống ${_formatCurrency(suggestedLimit)} để phù hợp hơn.';
    } else {
      reason = 'Ngân sách hiện tại của bạn phù hợp với mức chi tiêu trung bình '
          '${_formatCurrency(averageMonthlySpending)}/tháng.';
    }

    return BudgetSuggestion(
      suggestedLimit: suggestedLimit.toDouble(),
      reason: reason,
      confidence: confidence,
      averageSpending: averageMonthlySpending,
      currentLimit: currentLimit,
    );
  }

  /// Gợi ý phân bổ ngân sách
  static Future<List<BudgetAllocationSuggestion>> suggestBudgetAllocation({
    required String userId,
    required num totalBudget,
    int monthsBack = 3,
  }) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - monthsBack, 1);
    
    // Lấy tất cả transactions chi tiêu trong 3 tháng gần nhất
    final transactions = await _client
        .from('transactions')
        .select('amount, category_id')
        .eq('user_id', userId)
        .eq('type', 'EXPENSE')
        .gte('occurred_at', startDate.toIso8601String());

    // Tính tổng chi tiêu theo category
    final Map<String, num> spendingByCategory = {};
    num totalSpending = 0;
    
    for (final tx in transactions) {
      final categoryId = tx['category_id'] as String?;
      if (categoryId == null) continue;
      
      final amount = (tx['amount'] as num?) ?? 0;
      spendingByCategory[categoryId] = (spendingByCategory[categoryId] ?? 0) + amount;
      totalSpending += amount;
    }

    if (totalSpending == 0) {
      return [];
    }

    // Lấy tên category
    final categoryIds = spendingByCategory.keys.toList();
    if (categoryIds.isEmpty) return [];
    
    // Query từng category hoặc dùng filter
    final categories = <Map<String, dynamic>>[];
    for (final categoryId in categoryIds) {
      try {
        final result = await _client
            .from('categories')
            .select('id, name')
            .eq('id', categoryId)
            .maybeSingle();
        if (result != null) {
          categories.add(result);
        }
      } catch (e) {
        // Bỏ qua nếu lỗi
      }
    }

    final categoryMap = Map<String, String>.fromEntries(
      (categories as List).map((c) => MapEntry(
        c['id'] as String,
        c['name'] as String? ?? '',
      )),
    );

    // Tính phần trăm và đề xuất phân bổ
    final suggestions = <BudgetAllocationSuggestion>[];
    
    spendingByCategory.forEach((categoryId, amount) {
      final percentage = (amount / totalSpending) * 100;
      final suggestedAmount = (totalBudget * percentage / 100).round();
      
      suggestions.add(BudgetAllocationSuggestion(
        categoryId: categoryId,
        categoryName: categoryMap[categoryId] ?? 'Không xác định',
        suggestedAmount: suggestedAmount,
        percentage: percentage,
        currentAverage: amount / monthsBack, // Trung bình mỗi tháng
      ));
    });

    // Sắp xếp theo số tiền giảm dần
    suggestions.sort((a, b) => b.suggestedAmount.compareTo(a.suggestedAmount));

    return suggestions;
  }

  static String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toStringAsFixed(0)} ₫';
  }
}

/// Gợi ý điều chỉnh ngân sách
class BudgetSuggestion {
  final double suggestedLimit;
  final String reason;
  final double confidence; // 0.0 - 1.0
  final num? averageSpending;
  final num? currentLimit;

  BudgetSuggestion({
    required this.suggestedLimit,
    required this.reason,
    required this.confidence,
    this.averageSpending,
    this.currentLimit,
  });
}

/// Gợi ý phân bổ ngân sách
class BudgetAllocationSuggestion {
  final String categoryId;
  final String categoryName;
  final int suggestedAmount;
  final double percentage;
  final num currentAverage;

  BudgetAllocationSuggestion({
    required this.categoryId,
    required this.categoryName,
    required this.suggestedAmount,
    required this.percentage,
    required this.currentAverage,
  });
}

