import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thống kê'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Thu nhập',
                      amount: '15,000,000',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Chi tiêu',
                      amount: '8,500,000',
                      icon: Icons.trending_down,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Chart Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiêu theo danh mục',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _CategoryItem(
                      category: 'Nhu cầu thiết yếu',
                      amount: 3500000,
                      percentage: 41.2,
                      color: AppColors.error,
                      icon: Icons.home,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CategoryItem(
                      category: 'Giải trí',
                      amount: 2000000,
                      percentage: 23.5,
                      color: AppColors.warning,
                      icon: Icons.movie,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CategoryItem(
                      category: 'Di chuyển',
                      amount: 1500000,
                      percentage: 17.6,
                      color: AppColors.info,
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CategoryItem(
                      category: 'Giáo dục',
                      amount: 1000000,
                      percentage: 11.8,
                      color: AppColors.success,
                      icon: Icons.school,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CategoryItem(
                      category: 'Sức khỏe',
                      amount: 500000,
                      percentage: 5.9,
                      color: AppColors.primary,
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Monthly Comparison
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: AppShadows.cardShadow,
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
                    _MonthComparisonItem(
                      month: 'Tháng 11',
                      income: 12000000,
                      expense: 7500000,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MonthComparisonItem(
                      month: 'Tháng 12',
                      income: 15000000,
                      expense: 8500000,
                      isCurrent: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Spending Trend
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xu hướng chi tiêu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _TrendItem(
                      label: 'Tuần này',
                      amount: 2500000,
                      change: 12.5,
                      isPositive: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TrendItem(
                      label: 'Tháng này',
                      amount: 8500000,
                      change: 8.3,
                      isPositive: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _TrendItem(
                      label: 'Năm này',
                      amount: 95000000,
                      change: 15.2,
                      isPositive: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$amount ₫',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  const _CategoryItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    return '$formatted ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                ),
              ],
            ),
            Text(
              _formatCurrency(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.progressBar),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray500,
              ),
        ),
      ],
    );
  }
}

class _MonthComparisonItem extends StatelessWidget {
  final String month;
  final double income;
  final double expense;
  final bool isCurrent;

  const _MonthComparisonItem({
    required this.month,
    required this.income,
    required this.expense,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : AppColors.gray50,
        borderRadius: AppRadius.radiusMD,
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Text(
                    'Hiện tại',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ComparisonStat(
                  label: 'Thu nhập',
                  amount: income,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ComparisonStat(
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

class _ComparisonStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _ComparisonStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    return '$formatted ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray500,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _formatCurrency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _TrendItem extends StatelessWidget {
  final String label;
  final double amount;
  final double change;
  final bool isPositive;

  const _TrendItem({
    required this.label,
    required this.amount,
    required this.change,
    required this.isPositive,
  });

  String _formatCurrency(double value) {
    final formatter = value.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    return '$formatted ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
        ),
        Row(
          children: [
            Text(
              _formatCurrency(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isPositive
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusSM,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${change.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isPositive ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

