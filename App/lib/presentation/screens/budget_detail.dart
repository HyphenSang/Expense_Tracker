import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/presentation/screens/add_budget.dart';

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
  
  final _getCurrentUser = GetCurrentUser(DI.authRepository);
  
  bool get _isExpired {
    final endDateStr = widget.budget['endDate'] as String?;
    if (endDateStr == null) return false; // Không có end_date thì không hết hiệu lực
    final endDate = DateTime.parse(endDateStr);
    return DateTime.now().isAfter(endDate);
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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

      final startDateStr = widget.budget['startDate'] as String;
      final endDateStr = widget.budget['endDate'] as String?;
      final startDate = DateTime.parse(startDateStr);
      final endDate = endDateStr != null ? DateTime.parse(endDateStr) : DateTime.now();

      // Parse dates để lấy đúng range (bao gồm cả ngày cuối)
      final startDateTime = DateTime(startDate.year, startDate.month, startDate.day);
      final endDateTime = endDateStr != null
          ? DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1))
          : DateTime.now();

      if (widget.budget['type'] == 'category') {
        // Lấy transactions theo category_id
        final categoryId = widget.budget['categoryId'] as String?;
        if (categoryId != null) {
          final transactions = await SupabaseConfig.client
              .from('transactions')
              .select('id, amount, note, occurred_at, type')
              .eq('user_id', user.id)
              .eq('category_id', categoryId)
              .eq('type', 'EXPENSE')
              .gte('occurred_at', startDateTime.toIso8601String())
              .lt('occurred_at', endDateTime.toIso8601String())
              .order('occurred_at', ascending: false);

          _transactions = (transactions as List).map((tx) {
            return {
              'id': tx['id'] as String,
              'amount': tx['amount'] as num,
              'note': tx['note'] as String? ?? '',
              'occurredAt': DateTime.parse(tx['occurred_at'] as String),
            };
          }).toList();
        }
      } else if (widget.budget['type'] == 'jar') {
        // Lấy transactions từ jar_allocations
        final jarId = widget.budget['jarId'] as String?;
        if (jarId != null) {
          // Lấy jar_allocations trong khoảng thời gian
          final allocations = await SupabaseConfig.client
              .from('jar_allocations')
              .select('amount, transaction_id, transactions!inner(id, note, occurred_at, type)')
              .eq('jar_id', jarId);

          // Filter theo date range và lấy transactions
          final filteredAllocations = (allocations as List).where((a) {
            final transaction = a['transactions'] as Map<String, dynamic>?;
            if (transaction == null) return false;
            final occurredAtStr = transaction['occurred_at'] as String?;
            if (occurredAtStr == null) return false;
            final occurredAt = DateTime.parse(occurredAtStr);
            return occurredAt.isAfter(startDateTime.subtract(const Duration(seconds: 1))) &&
                occurredAt.isBefore(endDateTime);
          }).toList();

          _transactions = filteredAllocations.map((a) {
            final transaction = a['transactions'] as Map<String, dynamic>;
            return {
              'id': transaction['id'] as String,
              'amount': a['amount'] as num,
              'note': transaction['note'] as String? ?? '',
              'occurredAt': DateTime.parse(transaction['occurred_at'] as String),
            };
          }).toList();

          // Sắp xếp theo thời gian giảm dần
          _transactions.sort((a, b) => (b['occurredAt'] as DateTime).compareTo(a['occurredAt'] as DateTime));
        }
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
    final limit = widget.budget['limit'] as num;
    final spent = widget.budget['spent'] as num;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;
    final remaining = (limit - spent).clamp(0, limit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ngân sách'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to edit budget screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng chỉnh sửa sẽ được triển khai'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner thông báo khi budget hết hiệu lực
              if (_isExpired) _buildExpiredBanner(),
              
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
                            widget.budget['icon'] as IconData,
                            color: widget.budget['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.budget['name'] as String,
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
                                      color: widget.budget['type'] == 'category'
                                          ? AppColors.primaryLight
                                          : AppColors.info
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.budget['type'] == 'category'
                                          ? 'Danh mục'
                                          : 'Hũ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: widget.budget['type'] ==
                                                    'category'
                                                ? AppColors.gray900
                                                : AppColors.info,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    _getPeriodLabel(
                                        widget.budget['period'] as String),
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
                    
                    // Progress section
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
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOverBudget
                                  ? 'Vượt ngân sách: ${_formatCurrency(spent - limit)}'
                                  : 'Còn lại: ${_formatCurrency(remaining)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isOverBudget
                                        ? AppColors.error
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                            ),
                          ],
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
                // Hiển thị note nếu có
                if (note.isNotEmpty) ...[
                  Text(
                    note,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                // Hiển thị ngày giờ
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

