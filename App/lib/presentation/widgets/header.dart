import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/profile.dart';
import 'package:expenses/presentation/screens/notifications.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  
  const HomeHeader({
    super.key,
    required this.username,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (onProfileTap != null) {
                    onProfileTap!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.gray200,
                        child: Icon(Icons.person, color: AppColors.gray600),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Xin chào, $username',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                          Text(
                            'View Profile',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Icons Section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: null, // Vô hiệu hóa icon Settings
                icon: Icon(Icons.settings_outlined, color: AppColors.gray900),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: () {
                  if (onNotificationsTap != null) {
                    onNotificationsTap!();
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.notifications_outlined, color: AppColors.gray900),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ]),
    );
  }
}

