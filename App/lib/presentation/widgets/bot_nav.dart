import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.bottomNavShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, currentIndex == 0, onTap: () => onTap?.call(0)),
              _buildNavItem(Icons.account_balance_wallet, currentIndex == 1, onTap: () => onTap?.call(1)),
              _buildNavItem(Icons.add_circle_outline, false, isCenter: true, onTap: () => onTap?.call(2)),
              _buildNavItem(Icons.analytics_outlined, currentIndex == 3, onTap: () => onTap?.call(3)),
              _buildNavItem(Icons.person_outline, currentIndex == 4, onTap: () => onTap?.call(4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    bool isActive, {
    bool isCenter = false,
    VoidCallback? onTap,
  }) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.gray900,
            size: AppIconSizes.lg,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? AppColors.gray900 : AppColors.gray400,
        size: AppIconSizes.md,
      ),
    );
  }
}

