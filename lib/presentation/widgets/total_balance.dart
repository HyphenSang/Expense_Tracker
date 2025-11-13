import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class TotalBalanceSection extends StatelessWidget {
  final String balance;
  final bool isLinked;

  const TotalBalanceSection({
    super.key,
    required this.balance,
    this.isLinked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              if (isLinked)
                Row(
                  children: [
                    Icon(Icons.account_balance, size: AppIconSizes.xs, color: AppColors.gray500),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Linked',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            balance,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}

