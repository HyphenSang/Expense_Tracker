import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/presentation/screens/add_budget.dart';
import 'package:expenses/service/budget_insight.dart';
import 'package:expenses/service/budget_checker.dart';
import 'package:expenses/presentation/widgets/budget_progress_card.dart';

/// Màn hình chi tiết ngân sách.
///
/// Hiển thị thông tin chi tiết về một ngân sách cụ thể,
/// bao gồm progress, danh sách giao dịch liên quan, và các hành động.
class BudgetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> budget;

  const BudgetDetailScreen({
    super.key,
    required this.budget,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  BudgetInsight? _insight;
  Map<String, dynamic>? _currentBudget; // Lưu budget data hiện tại
  
  final _getCurrentUser = GetCurrentUser(DI.authRepository);
  
  Map<String, dynamic> get _budget => _currentBudget ?? widget.budget;
  
  bool get _isExpired {
    final endDateStr = _budget['endDate'] as String?;
    if (endDateStr == null) return false; // Không có end_date thì không hết hiệu lực
    final endDate = DateTime.parse(endDateStr);
    return DateTime.now().isAfter(endDate);
  }

  bool get _isPaused {
    return _budget['isPaused'] == true || _budget['is_paused'] == true;
  }

  @override
  void initState() {
    super.initState();
    _currentBudget = Map<String, dynamic>.from(widget.budget);
    _checkAndAutoPauseBudget();
    _loadTransactions();
    _loadInsight();
  }

  /// Kiểm tra và tự động pause budget nếu strict mode và đã vượt 100%
  Future<void> _checkAndAutoPauseBudget() async {
    try {
      final user = _getCurrentUser();
      if (user == null) return;

      final budgetId = _budget['id'] as String;
      final limit = _budget['limit'] as num;
      final spent = _budget['spent'] as num;
      final budgetMode = _budget['budgetMode'] as String? ?? 'reminder';

      // Chỉ pause nếu strict mode và đã vượt 100%
      if (budgetMode == 'strict' && spent >= limit) {
        await BudgetCheckerService.autoPauseBudgetIfNeeded(
          budgetId: budgetId,
          spentAmount: spent,
          limitAmount: limit,
          mode: BudgetMode.strict,
        );
        // Reload budget để cập nhật is_paused
        await _reloadBudget();
      }
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  /// Reload budget data từ database
  Future<void> _reloadBudget() async {
    try {
      final user = _getCurrentUser();
      if (user == null) return;

      final budgetId = _budget['id'] as String;
      
      // Load budget từ database
      final budgetRes = await SupabaseConfig.client
          .from('budgets')
          .select('*')
          .eq('id', budgetId)
          .single();

      // Load category
      final categoryId = budgetRes['category_id'] as String?;
      if (categoryId == null) return;

      final categoryRes = await SupabaseConfig.client
          .from('categories')
          .select('name, icon, color')
          .eq('id', categoryId)
          .single();

      // Parse color và icon
      Color? color;
      IconData? icon;
      final categoryName = categoryRes['name'] as String? ?? '';
      final categoryIcon = categoryRes['icon'] as String?;
      final categoryColor = categoryRes['color'] as String?;

      // Lấy default category nếu có
      final defaultCategories = _getDefaultExpenseCategories();
      final normalizedName = categoryName.toLowerCase().trim();
      final defaultCategory = defaultCategories[normalizedName];

      if (defaultCategory != null) {
        icon = defaultCategory['icon'] as IconData;
        color = defaultCategory['color'] as Color;
      } else if (categoryIcon != null && categoryColor != null) {
        try {
          color = Color(
            int.parse(categoryColor.replaceAll('#', ''), radix: 16) + 0xFF000000,
          );
        } catch (_) {
          color = AppColors.gray500;
        }
        icon = _getIconFromString(categoryIcon);
      } else {
        icon = Icons.category;
        color = AppColors.gray500;
      }

      final limit = (budgetRes['limit_amount'] as num?)?.toDouble() ?? 0.0;
      final spent = (budgetRes['spent_amount'] as num?)?.toDouble() ?? 0.0;

      // Cập nhật budget data
      setState(() {
        _currentBudget = {
          'id': budgetRes['id'] as String,
          'name': categoryName,
          'categoryId': categoryId,
          'categoryName': categoryName,
          'limit': limit,
          'spent': spent,
          'period': budgetRes['period'] as String? ?? 'MONTHLY',
          'startDate': budgetRes['start_date'] as String?,
          'endDate': budgetRes['end_date'] as String?,
          'budgetMode': budgetRes['budget_mode'] as String? ?? 'reminder',
          'isPaused': budgetRes['is_paused'] as bool? ?? false,
          'is_paused': budgetRes['is_paused'] as bool? ?? false, // Thêm cả key này để đảm bảo
          'icon': icon ?? Icons.category,
          'color': color ?? AppColors.gray500,
        };
      });

      // Reload transactions và insight với data mới
      _loadTransactions();
      _loadInsight();
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  Map<String, Map<String, dynamic>> _getDefaultExpenseCategories() {
    return {
      'chợ, siêu thị': {
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'ăn uống': {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFFFE651),
      },
      'di chuyển': {
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF42A5F5),
      },
      'mua sắm': {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFEC407A),
      },
      'giải trí': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFFAB47BC),
      },
      'học tập': {
        'icon': Icons.school_outlined,
        'color': const Color(0xFF7E57C2),
      },
    };
  }

  IconData _getIconFromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;
    switch (iconName.toLowerCase()) {
      case 'shopping_bag':
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'restaurant':
      case 'restaurant_outlined':
        return Icons.restaurant_outlined;
      case 'directions_car':
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'shopping_cart':
      case 'shopping_cart_outlined':
        return Icons.shopping_cart_outlined;
      case 'card_giftcard':
      case 'card_giftcard_outlined':
        return Icons.card_giftcard_outlined;
      case 'school':
      case 'school_outlined':
        return Icons.school_outlined;
      default:
        return Icons.category;
    }
  }

  Future<void> _loadInsight() async {
    try {
      final user = _getCurrentUser();
      if (user == null) return;

      final limit = _budget['limit'] as num;
      final spent = _budget['spent'] as num;
      final startDateStr = _budget['startDate'] as String;
      final endDateStr = _budget['endDate'] as String?;
      final period = _budget['period'] as String;
      final budgetId = _budget['id'] as String? ?? '';

      final startDate = DateTime.parse(startDateStr);
      final endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;

      final insight = await BudgetInsightService.calculateInsight(
        userId: user.id,
        budgetId: budgetId,
        limitAmount: limit,
        spentAmount: spent,
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      if (mounted) {
        setState(() {
          _insight = insight;
        });
      }
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _getCurrentUser();
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final startDateStr = _budget['startDate'] as String;
      final endDateStr = _budget['endDate'] as String?;
      final startDate = DateTime.parse(startDateStr);
      final endDate = endDateStr != null ? DateTime.parse(endDateStr) : DateTime.now();

      // Lấy transactions trong khoảng thời gian hiệu lực của budget (từ startDate đến endDate)
      // Đảm bảo logic nhất quán: chỉ lấy transactions trong khoảng thời gian budget có hiệu lực
      final startDateTime = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateTime = endDateStr != null
          ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
          : DateTime.now();

      // Lấy transactions theo category_id trong khoảng thời gian hiệu lực của budget
      final categoryId = _budget['categoryId'] as String?;
      if (categoryId != null) {
        final transactions = await SupabaseConfig.client
            .from('transactions')
            .select('id, amount, note, occurred_at, type')
            .eq('user_id', user.id)
            .eq('category_id', categoryId)
            .eq('type', 'EXPENSE')
            .gte('occurred_at', startDateTime.toIso8601String())
            .lte('occurred_at', endDateTime.toIso8601String())
            .order('occurred_at', ascending: false);

        _transactions = (transactions as List).map((tx) {
          return {
            'id': tx['id'] as String,
            'amount': tx['amount'] as num,
            'note': tx['note'] as String? ?? '',
            'occurredAt': DateTime.parse(tx['occurred_at'] as String),
          };
        }).toList();
      } else {
        _transactions = [];
      }
    } catch (e) {
      // Nếu có lỗi, để danh sách rỗng
      _transactions = [];
    }

    setState(() {
      _isLoading = false;
    });
  }


  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toStringAsFixed(0)} ₫';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'MONTHLY':
        return 'Hàng tháng';
      case 'WEEKLY':
        return 'Hàng tuần';
      case 'YEARLY':
        return 'Hàng năm';
      default:
        return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    final limit = _budget['limit'] as num;
    final spent = _budget['spent'] as num;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ngân sách'),
        centerTitle: true,
        actions: [
          // Chỉ hiển thị nút chỉnh sửa và xóa khi budget chưa hết thời gian
          if (!_isExpired) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                // Format budget data để truyền vào AddBudgetScreen
                final budgetData = {
                  'id': _budget['id'] as String,
                  'limit': _budget['limit'] as num,
                  'categoryId': _budget['categoryId'] as String?,
                  'categoryName': _budget['categoryName'] as String?,
                  'period': _budget['period'] as String,
                  'startDate': _budget['startDate'] as String,
                  'endDate': _budget['endDate'] as String?,
                  'budgetMode': _budget['budgetMode'] as String? ?? 'reminder',
                };
                
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddBudgetScreen(budgetToEdit: budgetData),
                  ),
                );
                
                // Reload budget data nếu đã được cập nhật
                if (result == true && mounted) {
                  await _reloadBudget();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showDeleteDialog();
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner thông báo khi budget hết hiệu lực
              if (_isExpired) _buildExpiredBanner(),
              // Banner thông báo khi budget bị tạm dừng
              if (_isPaused && !_isExpired) _buildPausedBanner(),
              
              // Header section với icon và tên
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: _isExpired ? AppColors.success.withValues(alpha: 0.05) : Colors.white,
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: (widget.budget['color'] as Color)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            _budget['icon'] as IconData,
                            color: _budget['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _budget['name'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray900,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Danh mục',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.gray900,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    _getPeriodLabel(
                                        _budget['period'] as String),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.gray500,
                                          fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Progress section với insights
                    if (_insight != null)
                      BudgetProgressCard(
                        insight: _insight!,
                        categoryName: _budget['name'] as String?,
                        jarName: null,
                      )
                    else
                      // Fallback nếu chưa load được insight
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đã chi',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.gray600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCurrency(spent),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isOverBudget
                                              ? AppColors.error
                                              : AppColors.gray900,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Giới hạn',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.gray600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCurrency(limit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.gray900,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.progressBar),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: AppColors.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOverBudget ? AppColors.error : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Thông tin ngân sách
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin ngân sách',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoRow(
                      'Ngày bắt đầu',
                      _formatDate(DateTime.parse(
                          widget.budget['startDate'] as String)),
                      Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(
                      'Ngày kết thúc',
                      widget.budget['endDate'] != null
                          ? _formatDate(DateTime.parse(
                              widget.budget['endDate'] as String))
                          : 'Không giới hạn',
                      Icons.event_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(
                      'Trạng thái',
                      widget.budget['isActive'] == true ? 'Đang hoạt động' : 'Đã tắt',
                      widget.budget['isActive'] == true
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: widget.budget['isActive'] == true
                          ? AppColors.success
                          : AppColors.gray400,
                    ),
                  ],
                ),
              ),

              // Danh sách giao dịch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Giao dịch liên quan',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                        ),
                        Text(
                          '${_transactions.length} giao dịch',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),

              // List transactions
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl * 2),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Chưa có giao dịch nào',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppColors.gray600,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),

              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.gray600,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as num;
    final note = transaction['note'] as String? ?? '';
    final occurredAt = transaction['occurredAt'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị tên giao dịch (ghi chú) - luôn hiển thị, trên ngày
                Text(
                  note.isNotEmpty ? note : 'Không có ghi chú',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: note.isNotEmpty ? AppColors.gray900 : AppColors.gray400,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Hiển thị ngày giờ - dưới tên giao dịch
                Text(
                  _formatDateTime(occurredAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '-${_formatCurrency(amount)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedBanner() {
    final budgetMode = _budget['budgetMode'] as String? ?? 'reminder';
    final limit = _budget['limit'] as num;
    final spent = _budget['spent'] as num;
    final isOverBudget = spent >= limit;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.2),
            AppColors.warning.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏸️ Ngân sách đã tạm dừng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      budgetMode == 'strict' && isOverBudget
                          ? 'Ngân sách đã vượt 100% ở chế độ nghiêm ngặt. Bạn vẫn có thể xem, chỉnh sửa hoặc tiếp tục ngân sách này.'
                          : 'Ngân sách này đã được tạm dừng. Bạn vẫn có thể xem, chỉnh sửa hoặc tiếp tục ngân sách này.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final budgetId = _budget['id'] as String;
                
                // Unpause budget
                await BudgetCheckerService.unpauseBudget(budgetId);
                
                if (!mounted) return;
                
                // Reload budget để cập nhật trạng thái từ database
                await _reloadBudget();
                
                if (!mounted) return;
                
                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã tiếp tục ngân sách'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi tiếp tục ngân sách: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Tiếp tục ngân sách'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredBanner() {
    final limit = widget.budget['limit'] as num;
    final spent = widget.budget['spent'] as num;
    final isSuccess = spent <= limit;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSuccess
              ? [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.success.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.warning.withValues(alpha: 0.2),
                  AppColors.warning.withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isSuccess ? Icons.celebration : Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSuccess
                          ? '🎉 Chúc mừng! Bạn đã hoàn thành ngân sách'
                          : '⚠️ Ngân sách đã hết hiệu lực',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSuccess ? AppColors.success : AppColors.warning,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isSuccess
                          ? 'Bạn đã tiết kiệm thành công trong khoảng thời gian này!'
                          : 'Ngân sách này đã kết thúc. Bạn có muốn tạo ngân sách mới không?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () async {
              // Quay về màn hình danh sách và mở màn hình tạo budget mới
              Navigator.of(context).pop(); // Đóng budget detail
              // Navigate đến AddBudgetScreen
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddBudgetScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Tạo ngân sách mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? AppColors.success : AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xóa ngân sách'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa ngân sách này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Đóng dialog
              
              // Hiển thị loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final budgetId = widget.budget['id'] as String;
                await DI.budgetRepository.deleteBudget(budgetId);
                
                if (!mounted) return;
                
                // Đóng loading
                Navigator.of(context).pop();
                
                // Quay về màn hình danh sách với flag refresh
                Navigator.of(context).pop(true);
                
                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa ngân sách thành công'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                // Đóng loading
                Navigator.of(context).pop();
                
                // Hiển thị thông báo lỗi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi xóa ngân sách: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

