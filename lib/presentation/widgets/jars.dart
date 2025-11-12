import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class SixJarsSection extends StatelessWidget {
  final VoidCallback? onViewAll;

  const SixJarsSection({
    super.key,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '6 Hũ Tài Chính',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    size: AppIconSizes.xs,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Grid 2x3 cho 6 hũ
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: JarCard(
                    name: 'Nhu cầu thiết yếu',
                    amount: '55,000,000 ₫',
                    percentage: '55%',
                    icon: Icons.home,
                    color: AppColors.error,
                    progress: 0.85,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: JarCard(
                    name: 'Tiết kiệm dài hạn',
                    amount: '10,000,000 ₫',
                    percentage: '10%',
                    icon: Icons.savings,
                    color: AppColors.info,
                    progress: 0.90,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: JarCard(
                    name: 'Giáo dục',
                    amount: '10,000,000 ₫',
                    percentage: '10%',
                    icon: Icons.school,
                    color: AppColors.warning,
                    progress: 0.75,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: JarCard(
                    name: 'Hưởng thụ',
                    amount: '10,000,000 ₫',
                    percentage: '10%',
                    icon: Icons.celebration,
                    color: AppColors.primary,
                    progress: 0.60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: JarCard(
                    name: 'Tự do tài chính',
                    amount: '10,000,000 ₫',
                    percentage: '10%',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.success,
                    progress: 0.50,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: JarCard(
                    name: 'Cho đi',
                    amount: '5,000,000 ₫',
                    percentage: '5%',
                    icon: Icons.favorite,
                    color: AppColors.error,
                    progress: 0.40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class JarCard extends StatelessWidget {
  final String name;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final double progress;

  const JarCard({
    super.key,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = progress < 0.5;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: isWarning ? AppColors.warning : AppColors.gray200,
          width: isWarning ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(icon, color: color, size: AppIconSizes.sm),
              ),
              if (isWarning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSpacing.xs / 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXS,
                  ),
                  child: Text(
                    '⚠️',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                percentage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          Container(
            height: 6.0,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.progressBar),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.progressBar),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

