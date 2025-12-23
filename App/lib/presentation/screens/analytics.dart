import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:expenses/service/expense_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<(
        ExpenseSummary,
        List<CategorySpendingSummary>,
        MonthlyComparison,
        List<SpendingTrendItem>
      )>(
        future: _loadAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          late ExpenseSummary summary;
          late List<CategorySpendingSummary> categories;
          late MonthlyComparison comparison;
          late List<SpendingTrendItem> trends;

          if (snapshot.hasError || !snapshot.hasData) {
            // Fallback dữ liệu mẫu nếu có lỗi khi gọi Supabase
            summary = const ExpenseSummary(
              totalBalance: SampleData.totalBalance,
              monthlyIncome: SampleData.monthlyIncome,
              monthlyExpense: SampleData.monthlyExpense,
              monthlySaved: SampleData.monthlySaved,
            );
            categories = const [
              CategorySpendingSummary(
                name: 'Nhu cầu thiết yếu',
                amount: 3500000,
                percentage: 41.2,
              ),
              CategorySpendingSummary(
                name: 'Giải trí',
                amount: 2000000,
                percentage: 23.5,
              ),
              CategorySpendingSummary(
                name: 'Di chuyển',
                amount: 1500000,
                percentage: 17.6,
              ),
              CategorySpendingSummary(
                name: 'Giáo dục',
                amount: 1000000,
                percentage: 11.8,
              ),
              CategorySpendingSummary(
                name: 'Sức khỏe',
                amount: 500000,
                percentage: 5.9,
              ),
            ];
            comparison = const MonthlyComparison(
              previousMonthLabel: 'Tháng 11',
              currentMonthLabel: 'Tháng 12',
              previousIncome: '12.000.000 ₫',
              previousExpense: '7.500.000 ₫',
              currentIncome: '15.000.000 ₫',
              currentExpense: '8.500.000 ₫',
            );
            trends = const [
              SpendingTrendItem(
                label: 'Tuần này',
                amount: '2.500.000 ₫',
                changePercent: '12.5%',
                isIncrease: false,
              ),
              SpendingTrendItem(
                label: 'Tháng này',
                amount: '8.500.000 ₫',
                changePercent: '8.3%',
                isIncrease: false,
              ),
              SpendingTrendItem(
                label: 'Năm này',
                amount: '95.000.000 ₫',
                changePercent: '15.2%',
                isIncrease: true,
              ),
            ];
          } else {
            (summary, categories, comparison, trends) = snapshot.data!;
          }

          return ListView(
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
              _IncomeExpenseRow(summary: summary),
              const SizedBox(height: AppSpacing.xl),
              _CategorySpendingCard(categories: categories),
              const SizedBox(height: AppSpacing.xl),
              _MonthlyComparisonCard(comparison: comparison),
              const SizedBox(height: AppSpacing.xl),
              _SpendingTrendCard(trends: trends),
            ],
          );
        },
      ),
    );
  }

  Future<(
    ExpenseSummary,
    List<CategorySpendingSummary>,
    MonthlyComparison,
    List<SpendingTrendItem>
  )> _loadAnalytics() async {
    final summary = await ExpenseService.getSummary();
    final categories = await ExpenseService.getCategorySpendingForCurrentMonth();
    final comparison = await ExpenseService.getMonthlyComparison();
    final trends = await ExpenseService.getSpendingTrends();
    return (summary, categories, comparison, trends);
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


