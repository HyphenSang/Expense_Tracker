import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Chế độ ngân sách
enum BudgetMode {
  /// Chế độ nhắc nhở: Cảnh báo nhưng vẫn cho phép thêm giao dịch
  reminder,
  
  /// Chế độ cảnh báo mạnh: Yêu cầu xác nhận 2 lần và ghi lý do
  warning,
  
  /// Chế độ nghiêm ngặt: Tự động pause khi đạt 100%, yêu cầu lý do bắt buộc
  strict,
}

/// Service kiểm tra và cảnh báo ngân sách với thông báo nhẹ nhàng
class BudgetCheckerService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Kết quả kiểm tra ngân sách
  static const String statusOk = 'OK';
  static const String statusWarning = 'WARNING'; // 75-90%
  static const String statusCritical = 'CRITICAL'; // 90-100%
  static const String statusExceeded = 'EXCEEDED'; // >100%

  /// Kiểm tra ngân sách cho category và ngày cụ thể
  static Future<BudgetCheckResult> checkBudget({
    required String userId,
    required String categoryId,
    required DateTime transactionDate,
    required num transactionAmount,
  }) async {
    try {
      // Lấy tất cả budgets active của user có category_id này
      final budgets = await _client
          .from('budgets')
          .select('*')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('is_active', true);

      if (budgets.isEmpty) {
        return BudgetCheckResult(
          status: statusOk,
          message: null,
          budget: null,
          projectedSpent: 0,
          overBudgetAmount: 0,
          budgetMode: BudgetMode.reminder,
        );
      }

      // Tìm budget phù hợp với transaction date
      Map<String, dynamic>? matchingBudget;
      for (final budget in budgets) {
        final startDate = DateTime.parse(budget['start_date'] as String);
        final endDateStr = budget['end_date'] as String?;
        final endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;

        if (transactionDate.isBefore(startDate)) continue;
        if (endDate != null && transactionDate.isAfter(endDate)) continue;

        matchingBudget = budget;
        break;
      }

      if (matchingBudget == null) {
        return BudgetCheckResult(
          status: statusOk,
          message: null,
          budget: null,
          projectedSpent: 0,
          overBudgetAmount: 0,
          budgetMode: BudgetMode.reminder,
        );
      }

      // Lấy chế độ ngân sách (mặc định là reminder)
      final modeStr = matchingBudget['budget_mode'] as String? ?? 'reminder';
      final budgetMode = BudgetMode.values.firstWhere(
        (m) => m.name == modeStr,
        orElse: () => BudgetMode.reminder,
      );

      // Kiểm tra nếu budget đã bị pause
      final isPaused = matchingBudget['is_paused'] as bool? ?? false;
      if (isPaused && budgetMode == BudgetMode.strict) {
        return BudgetCheckResult(
          status: statusExceeded,
          message: 'Ngân sách đã bị tạm dừng (đã đạt 100%)',
          budget: matchingBudget,
          projectedSpent: (matchingBudget['spent_amount'] as num?) ?? 0,
          overBudgetAmount: 0,
          budgetMode: budgetMode,
          isPaused: true,
        );
      }

      // Tính spent amount hiện tại và sau khi thêm transaction
      final limitAmount = (matchingBudget['limit_amount'] as num?) ?? 0;
      final currentSpent = (matchingBudget['spent_amount'] as num?) ?? 0;
      final newSpent = currentSpent + transactionAmount;
      final overBudgetAmount = newSpent > limitAmount ? (newSpent - limitAmount) : 0;
      
      // Xác định trạng thái
      String status;
      String? message;
      final percentage = limitAmount > 0 ? (newSpent / limitAmount) * 100 : 0;
      
      if (percentage >= 100) {
        status = statusExceeded;
        message = _generateFriendlyExceededMessage(overBudgetAmount);
      } else if (percentage >= 90) {
        status = statusCritical;
        message = _generateFriendlyCriticalMessage(percentage.toDouble());
      } else if (percentage >= 75) {
        status = statusWarning;
        message = _generateFriendlyWarningMessage(percentage.toDouble());
      } else {
        status = statusOk;
        message = null;
      }

      return BudgetCheckResult(
        status: status,
        message: message,
        budget: matchingBudget,
        projectedSpent: newSpent,
        overBudgetAmount: overBudgetAmount,
        percentage: percentage.toDouble(),
        budgetMode: budgetMode,
        isPaused: isPaused,
      );
    } catch (e) {
      return BudgetCheckResult(
        status: statusOk,
        message: null,
        budget: null,
        projectedSpent: 0,
        overBudgetAmount: 0,
        budgetMode: BudgetMode.reminder,
      );
    }
  }

  /// Tạo thông điệp nhẹ nhàng khi vượt ngân sách
  static String _generateFriendlyExceededMessage(num overAmount) {
    return 'Bạn đã vượt ngân sách ${_formatCurrency(overAmount)}. '
        'Có muốn ghi lý do để nhớ lần sau không?';
  }

  /// Tạo thông điệp nhẹ nhàng khi gần hết
  static String _generateFriendlyCriticalMessage(double percentage) {
    return 'Bạn đã dùng ${percentage.toStringAsFixed(0)}% ngân sách. '
        'Hãy chi tiêu cẩn thận nhé! 💪';
  }

  /// Tạo thông điệp nhẹ nhàng khi cảnh báo
  static String _generateFriendlyWarningMessage(double percentage) {
    return 'Bạn đã dùng ${percentage.toStringAsFixed(0)}% ngân sách. '
        'Còn ${(100 - percentage).toStringAsFixed(0)}% nữa.';
  }

  /// Lưu lý do vượt ngân sách
  static Future<void> saveOverBudgetReason({
    required String budgetId,
    required String reason,
    required num overBudgetAmount,
  }) async {
    try {
      await _client
          .from('budgets')
          .update({
            'over_budget_amount': overBudgetAmount,
            'over_budget_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', budgetId);
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  /// Tự động pause budget khi đạt 100% (chế độ Strict)
  static Future<void> autoPauseBudgetIfNeeded({
    required String budgetId,
    required num spentAmount,
    required num limitAmount,
    required BudgetMode mode,
  }) async {
    if (mode != BudgetMode.strict) return;
    if (spentAmount < limitAmount) return;

    try {
      await _client
          .from('budgets')
          .update({
            'is_paused': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', budgetId);
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  /// Tự động pause tất cả budgets strict mode đã vượt 100% (chạy khi load budgets)
  static Future<void> autoPauseOverBudgetStrictBudgets(String userId) async {
    try {
      // Lấy tất cả budgets strict mode đang active và chưa pause
      final budgets = await _client
          .from('budgets')
          .select('id, limit_amount, spent_amount, budget_mode, is_paused')
          .eq('user_id', userId)
          .eq('is_active', true)
          .eq('budget_mode', 'strict')
          .eq('is_paused', false);

      for (final budget in budgets) {
        final limitAmount = (budget['limit_amount'] as num?) ?? 0;
        final spentAmount = (budget['spent_amount'] as num?) ?? 0;
        
        // Nếu đã vượt 100%, tự động pause
        if (spentAmount >= limitAmount) {
          await _client
              .from('budgets')
              .update({
                'is_paused': true,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', budget['id'] as String);
        }
      }
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  /// Unpause budget
  static Future<void> unpauseBudget(String budgetId) async {
    try {
      await _client
          .from('budgets')
          .update({
            'is_paused': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', budgetId);
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
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

/// Kết quả kiểm tra ngân sách
class BudgetCheckResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? budget;
  final num projectedSpent;
  final num overBudgetAmount;
  final double? percentage;
  final BudgetMode budgetMode;
  final bool isPaused;

  BudgetCheckResult({
    required this.status,
    this.message,
    this.budget,
    required this.projectedSpent,
    required this.overBudgetAmount,
    this.percentage,
    required this.budgetMode,
    this.isPaused = false,
  });

  bool get isOk => status == BudgetCheckerService.statusOk;
  bool get isWarning => status == BudgetCheckerService.statusWarning;
  bool get isCritical => status == BudgetCheckerService.statusCritical;
  bool get isExceeded => status == BudgetCheckerService.statusExceeded;
  
  bool get needsReason {
    if (budgetMode == BudgetMode.strict) {
      return isCritical || isExceeded;
    } else if (budgetMode == BudgetMode.warning) {
      return isExceeded;
    }
    return false;
  }

  bool get needsDoubleConfirmation {
    if (budgetMode == BudgetMode.warning) {
      return isCritical || isExceeded;
    } else if (budgetMode == BudgetMode.strict) {
      return isExceeded;
    }
    return false;
  }

  bool get canAddTransaction {
    if (isPaused && budgetMode == BudgetMode.strict) {
      return false;
    }
    return true;
  }
}

