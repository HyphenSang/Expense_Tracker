import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/expense.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  String? _error;
  ExpenseSummary? _summary;
  List<CategorySpendingSummary>? _categories;
  MonthlyComparison? _comparison;
  List<SpendingTrendItem>? _trends;

  // Use cases
  final _getSummary = GetExpenseSummary(DI.expenseRepository);
  final _getCategoryData = GetCategoryData(DI.expenseRepository);
  final _getAnalytics = GetAnalytics(DI.expenseRepository);

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      
      final results = await Future.wait([
        _getSummary.forMonth(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
        _getCategoryData.getSpending(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
        _getAnalytics.getMonthComparison(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
        _getAnalytics.getSpendingTrends(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
      ]);

      final summary = results[0] as ExpenseSummary;
      final categories = results[1] as List<CategorySpendingSummary>;
      final comparison = results[2] as MonthlyComparison;
      final trends = results[3] as List<SpendingTrendItem>;

      if (mounted) {
        setState(() {
          _summary = summary;
          _categories = categories;
          _comparison = comparison;
          _trends = trends;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể tải dữ liệu: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải dữ liệu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị lỗi nếu có
    if (_error != null && _summary == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Không thể tải dữ liệu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                    _loadAnalytics();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Nếu chưa có dữ liệu và đang loading
    if (_summary == null) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _summary!;
    final categories = _categories ?? [];
    final comparison = _comparison;
    final trends = _trends ?? [];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        children: [
          Text(
            'Thống kê',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Theo dõi thu nhập, chi tiêu và xu hướng tài chính của bạn.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray500,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Month selector - Luôn hiển thị
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _isLoading ? null : () => _changeMonth(-1),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tháng ${_selectedMonth.month}/${_selectedMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _isLoading ? null : () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Nội dung - Hiển thị loading ở dưới nếu đang load
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _IncomeExpenseRow(summary: summary),
            const SizedBox(height: AppSpacing.xl),
            if (categories.isNotEmpty) ...[
              _CategorySpendingCard(categories: categories),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (comparison != null) ...[
              _MonthlyComparisonCard(comparison: comparison),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (trends.isNotEmpty) ...[
              _SpendingTrendCard(trends: trends),
            ],
          ],
        ],
      ),
    );
  }
}

/// Hàng trên cùng: Thu nhập / Chi tiêu (tháng hiện tại).
class _IncomeExpenseRow extends StatelessWidget {
  final ExpenseSummary summary;

  const _IncomeExpenseRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Thu nhập',
            amount: summary.monthlyIncome,
            icon: Icons.trending_up,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _SummaryCard(
            label: 'Chi tiêu',
            amount: summary.monthlyExpense,
            icon: Icons.trending_down,
            iconColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card "Chi tiêu theo danh mục".
class _CategorySpendingCard extends StatelessWidget {
  final List<CategorySpendingSummary> categories;

  const _CategorySpendingCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = <Color>[
      AppColors.error,   // Nhu cầu thiết yếu
      AppColors.info,    // Tiết kiệm dài hạn
      AppColors.warning, // Giáo dục
      AppColors.primary, // Hưởng thụ
      AppColors.success, // Tự do tài chính
      AppColors.error,   // Cho đi
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiêu theo danh mục',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < categories.length && i < 6; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categories[i].name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      Text(
                        ExpenseService.formatCurrency(categories[i].amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value:
                        (categories[i].percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.gray100,
                    color: colors[i],
                    minHeight: 4,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${categories[i].percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Card so sánh tháng trước / tháng này.
class _MonthlyComparisonCard extends StatelessWidget {
  final MonthlyComparison comparison;

  const _MonthlyComparisonCard({required this.comparison});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'So sánh tháng',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MonthlyRow(
            label: comparison.previousMonthLabel,
            income: comparison.previousIncome,
            expense: comparison.previousExpense,
            isCurrent: false,
          ),
          const SizedBox(height: AppSpacing.md),
          _MonthlyRow(
            label: comparison.currentMonthLabel,
            income: comparison.currentIncome,
            expense: comparison.currentExpense,
            isCurrent: true,
          ),
        ],
      ),
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final String label;
  final String income;
  final String expense;
  final bool isCurrent;

  const _MonthlyRow({
    required this.label,
    required this.income,
    required this.expense,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.gray50,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: isCurrent ? AppColors.primary : Colors.transparent,
          width: isCurrent ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Hiện tại',
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MonthlyValue(
                  label: 'Thu nhập',
                  amount: income,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _MonthlyValue(
                  label: 'Chi tiêu',
                  amount: expense,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyValue extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _MonthlyValue({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// Card xu hướng chi tiêu (tuần này / tháng này / năm này).
class _SpendingTrendCard extends StatelessWidget {
  final List<SpendingTrendItem> trends;

  const _SpendingTrendCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xu hướng chi tiêu',
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...trends.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray800,
                          ),
                    ),
                  ),
                  Text(
                    t.amount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: t.isIncrease
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t.isIncrease
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: t.isIncrease ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.changePercent,
                          style: theme.textTheme.labelSmall?.copyWith(
                                color: t.isIncrease
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


