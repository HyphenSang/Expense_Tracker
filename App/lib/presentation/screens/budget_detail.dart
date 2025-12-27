import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load transactions từ API
    // Nếu là category: lấy transactions theo category_id
    // Nếu là jar: lấy transactions từ jar_allocations theo jar_id
    
    // Dữ liệu mẫu dựa trên CSV
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Giả lập dữ liệu giao dịch
    _transactions = _generateSampleTransactions();

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _generateSampleTransactions() {
    // Dữ liệu mẫu dựa trên transactions_rows.csv
    if (widget.budget['type'] == 'category') {
      final categoryId = widget.budget['categoryId'] as String?;
      
      // Mẫu giao dịch cho "Mua sắm"
      if (categoryId == '5e3d2c7f-c151-44e3-929f-e8a43cca12f7') {
        return [
          {
            'id': '1',
            'amount': 30000,
            'note': 'Mua đồ dùng cá nhân',
            'occurredAt': DateTime(2025, 12, 24, 21, 0),
          },
          {
            'id': '2',
            'amount': 1500000,
            'note': 'Mua quần áo',
            'occurredAt': DateTime(2025, 12, 17, 20, 32),
          },
          {
            'id': '3',
            'amount': 300000,
            'note': 'Mua sắm online',
            'occurredAt': DateTime(2025, 12, 24, 21, 7),
          },
        ];
      }
      
      // Mẫu giao dịch cho "Di chuyển"
      if (categoryId == 'f7790789-1ec8-40b5-9459-88017ecbaa7e') {
        return [
          {
            'id': '1',
            'amount': 100000,
            'note': 'Xăng xe',
            'occurredAt': DateTime(2025, 12, 24, 20, 59),
          },
          {
            'id': '2',
            'amount': 50000,
            'note': 'Gửi xe',
            'occurredAt': DateTime(2025, 12, 24, 21, 33),
          },
          {
            'id': '3',
            'amount': 70000,
            'note': 'Taxi',
            'occurredAt': DateTime(2025, 12, 25, 22, 12),
          },
          {
            'id': '4',
            'amount': 65000,
            'note': 'Grab',
            'occurredAt': DateTime(2025, 12, 25, 20, 9),
          },
        ];
      }
    }
    
    // Mẫu giao dịch cho jar
    if (widget.budget['type'] == 'jar') {
      return [
        {
          'id': '1',
          'amount': 1000000,
          'note': 'Tiết kiệm tháng 12',
          'occurredAt': DateTime(2025, 12, 17, 13, 0),
        },
        {
          'id': '2',
          'amount': 500000,
          'note': 'Tiết kiệm bổ sung',
          'occurredAt': DateTime(2025, 12, 24, 14, 0),
        },
      ];
    }
    
    return [];
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
              // Header section với icon và tên
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
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
    final note = transaction['note'] as String? ?? 'Không có ghi chú';
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
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: 4),
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

