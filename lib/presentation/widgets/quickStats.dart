import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class QuickStatsSection extends StatelessWidget {
  final String income;
  final String expense;
  final String saved;

  const QuickStatsSection({
    super.key,
    required this.income,
    required this.expense,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Row(
        children: [
          Expanded(
            child: StatItem(
              label: 'Income',
              amount: income,
              color: AppColors.success,
              icon: Icons.trending_up,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          Expanded(
            child: StatItem(
              label: 'Expense',
              amount: expense,
              color: AppColors.error,
              icon: Icons.trending_down,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.gray200),
          Expanded(
            child: StatItem(
              label: 'Saved',
              amount: saved,
              color: AppColors.primary,
              icon: Icons.savings,
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const StatItem({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppIconSizes.sm),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

