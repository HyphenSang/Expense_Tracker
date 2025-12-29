import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/budget_insight.dart';

/// Widget hiển thị progress bar và thông tin chi tiết về ngân sách
class BudgetProgressCard extends StatelessWidget {
  final BudgetInsight insight;
  final String? categoryName;
  final String? jarName;

  const BudgetProgressCard({
    super.key,
    required this.insight,
    this.categoryName,
    this.jarName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Xác định màu sắc dựa trên trạng thái
    Color progressColor;
    Color backgroundColor;
    
    if (insight.status == 'exceeded') {
      progressColor = AppColors.error;
      backgroundColor = AppColors.error.withValues(alpha: 0.1);
    } else if (insight.status == 'critical') {
      progressColor = AppColors.error;
      backgroundColor = AppColors.error.withValues(alpha: 0.1);
    } else if (insight.status == 'warning') {
      progressColor = AppColors.warning;
      backgroundColor = AppColors.warning.withValues(alpha: 0.1);
    } else {
      progressColor = AppColors.success;
      backgroundColor = AppColors.success.withValues(alpha: 0.1);
    }

    // Tính progress (clamp để không vượt quá 100%)
    final progress = (insight.percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tên ngân sách
          if (categoryName != null || jarName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                categoryName ?? jarName ?? 'Ngân sách',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Thông tin số tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đã chi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatCurrency(insight.spentAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hạn mức',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatCurrency(insight.limitAmount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Thông tin chi tiết
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông điệp thân thiện
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(insight.status),
                      size: 20,
                      color: progressColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        BudgetInsightService.generateFriendlyMessage(insight),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),

                // Gợi ý (nếu có)
                if (BudgetInsightService.generateSuggestion(insight) != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            BudgetInsightService.generateSuggestion(insight)!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Thông tin bổ sung
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      Icons.calendar_today,
                      'Còn ${insight.daysRemaining} ngày',
                      AppColors.gray600,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _buildInfoItem(
                      context,
                      Icons.trending_up,
                      'TB: ${_formatCurrency(insight.averageSpendingPerDay)}/ngày',
                      AppColors.gray600,
                    ),
                  ],
                ),

                // Dự đoán ngày hết ngân sách (nếu có)
                if (insight.projectedExhaustionDate != null &&
                    insight.status != 'exceeded') ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Nếu tiếp tục chi tiêu như hiện tại, bạn sẽ hết ngân sách vào ngày '
                            '${_formatDate(insight.projectedExhaustionDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'exceeded':
        return Icons.warning_rounded;
      case 'critical':
        return Icons.warning_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline;
    }
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
    return '${date.day}/${date.month}/${date.year}';
  }
}

