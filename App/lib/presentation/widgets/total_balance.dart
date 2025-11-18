// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

@immutable
class TotalBalanceInfo {
  final String balance;
  final bool isLinked;
  final String currency;
  final String bankName;
  final String accountNumber;

  const TotalBalanceInfo({
    this.balance = '0',
    this.isLinked = true,
    this.currency = 'VND',
    this.bankName = 'VCB',
    this.accountNumber = '****123',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TotalBalanceInfo &&
        balance == other.balance &&
        isLinked == other.isLinked &&
        currency == other.currency &&
        bankName == other.bankName &&
        accountNumber == other.accountNumber;
  }

  @override
  int get hashCode => Object.hash(
        balance,
        isLinked,
        currency,
        bankName,
        accountNumber,
      );
}

class TotalBalanceSection extends StatelessWidget {
  final TotalBalanceInfo info;
  final VoidCallback? onBankSelect;
  final double shrinkOffset; 

  const TotalBalanceSection({
    super.key, 
    this.info = const TotalBalanceInfo(),
    this.onBankSelect,
    this.shrinkOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = shrinkOffset <= 0.5;
    
    final linkedBadgeOpacity = (1.0 - shrinkOffset * 1.5).clamp(0.0, 1.0);
    final horizontalPadding = isExpanded ? AppSpacing.lg : AppSpacing.xl;
    final verticalPadding = AppSpacing.lg * (1.0 - shrinkOffset * 0.5);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.cardShadow,
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: isExpanded
              ? _buildExpandedLayout(
                  context: context,
                  linkedBadgeOpacity: linkedBadgeOpacity,
                )
              : _buildCollapsedLayout(context),
        ),
      ),
    );
  }

  Widget _buildExpandedLayout({
    required BuildContext context,
    required double linkedBadgeOpacity,
  }) {
    return Container(
      key: const ValueKey('totalBalanceExpanded'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg * (1.0 - shrinkOffset * 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildLinkedBadge(context, linkedBadgeOpacity),
                    SizedBox(height: AppSpacing.xs * (1.0 - shrinkOffset * 0.3)),
                    _buildBankInfo(context),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceLabel(
                  context,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: AppSpacing.xs * (1.0 - shrinkOffset * 0.5)),
                _buildBalanceRow(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedLayout(BuildContext context) {
    return Row(
          key: const ValueKey('totalBalanceCollapsed'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBalanceLabel(
                      context,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildBalanceRow(context),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (info.isLinked)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Linked account',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.gray600,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  SizedBox(height: info.isLinked ? AppSpacing.xs : 0),
                  _buildBankInfo(context),
                ],
              ),
          ],
    );
  }

  Widget _buildBankInfo(BuildContext context) {
    return GestureDetector(
      onTap: onBankSelect,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md * (1.0 - shrinkOffset * 0.2),
          vertical: AppSpacing.sm * (1.0 - shrinkOffset * 0.3),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${info.bankName} ${info.accountNumber}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.gray800,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(width: AppSpacing.xs * (1.0 - shrinkOffset * 0.5)),
            Icon(
              Icons.keyboard_arrow_down,
              size: AppIconSizes.sm * (1.0 - shrinkOffset * 0.2),
              color: AppColors.gray700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            info.balance,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            info.currency,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedBadge(BuildContext context, double opacity) {
    if (!info.isLinked) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance,
              size: AppIconSizes.xs,
              color: AppColors.gray700,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Linked',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceLabel(
    BuildContext context, {
    required Color color,
    required FontWeight fontWeight,
  }) {
    return Text(
      'Your Balance',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: fontWeight,
          ),
    );
  }
}

class TotalBalanceSliverDelegate extends SliverPersistentHeaderDelegate {
  final TotalBalanceInfo info;
  final VoidCallback? onBankSelect;

  TotalBalanceSliverDelegate({
    this.info = const TotalBalanceInfo(),
    this.onBankSelect,
  });

  @override
  double get minExtent {
    const collapsedHeight = 70.0;
    const verticalPadding = AppSpacing.lg * 2;
    return collapsedHeight + verticalPadding;
  }

  @override
  double get maxExtent {
    const expandedHeight = 170.0;
    const verticalPadding = AppSpacing.lg * 2;
    return expandedHeight + verticalPadding;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final actualMaxExtent = maxExtent;
    final actualMinExtent = minExtent;
    
    final currentHeight = (actualMaxExtent - shrinkOffset).clamp(actualMinExtent, actualMaxExtent);
    final shrinkPercentage = (shrinkOffset / (actualMaxExtent - actualMinExtent)).clamp(0.0, 1.0);
    
    return SizedBox(
      height: currentHeight,
      child: TotalBalanceSection(
        info: info,
        onBankSelect: onBankSelect,
        shrinkOffset: shrinkPercentage,
      ),
    );
  }
  
  @override
  bool shouldRebuild(covariant TotalBalanceSliverDelegate oldDelegate) {
    return info != oldDelegate.info;
  }
}
