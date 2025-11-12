import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class ReminderBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onViewDetails;

  const ReminderBanner({
    super.key,
    required this.message,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.reminderBanner,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.warning, size: AppIconSizes.sm),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Nhắc nhở tiết kiệm',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: onViewDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.gray900,
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Text(
                      'Xem chi tiết',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: AppColors.gray900,
              size: AppIconSizes.xl,
            ),
          ),
        ],
      ),
    );
  }
}

