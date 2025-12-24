import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/profile.dart';
import 'package:expenses/presentation/screens/notifications.dart';
import 'package:expenses/service/notification_realtime.dart';

class HomeHeader extends StatefulWidget {
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
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  int _unreadCount = 0;
  StreamSubscription<int>? _unreadCountSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  void _listenToNotifications() {
    // Lắng nghe số lượng thông báo chưa đọc
    _unreadCountSubscription = NotificationRealtimeService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

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
                  if (widget.onProfileTap != null) {
                    widget.onProfileTap!();
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
                            'Xin chào, ${widget.username}',
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.onNotificationsTap != null) {
                        widget.onNotificationsTap!();
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
                  if (_unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: EdgeInsets.all(_unreadCount > 9 ? 2 : 4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            _unreadCount > 9 ? '9+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ]),
    );
  }
}

