import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/auth_service.dart';
import 'package:expenses/service/user_service.dart';
import 'package:expenses/presentation/screens/welcome.dart';
import 'package:expenses/presentation/screens/help.dart';
import 'package:expenses/presentation/screens/notifications.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/usecases/preference/get_notifications_enabled.dart';

/// Màn hình hồ sơ người dùng.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String _username = '';
  String _email = '';
  bool _notificationsEnabled = true;

  final _getNotificationsEnabled = GetNotificationsEnabled(DI.preferenceRepository);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final notifications = await _getNotificationsEnabled();

      if (!mounted) return;
      setState(() {
        _notificationsEnabled = notifications;
      });
    } catch (e) {
      // Nếu lỗi, giữ giá trị mặc định
    }
  }

  Future<void> _loadProfile() async {
    final user = AuthService.getUser();
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _email = user.email ?? '';
    });

    try {
      var profile = await UserService.getCurrentUserProfile();
      profile ??= await UserService.ensureCurrentUserProfile();

      if (!mounted) return;

      setState(() {
        _username = profile?.username ??
            profile?.fullName ??
            user.userMetadata?['username'] as String? ??
            user.email?.split('@').first ??
            'User';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin hồ sơ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(
            color: AppColors.gray700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await AuthService.signOut();
      if (!mounted) return;
      
      // Navigate về WelcomeScreen và xóa tất cả routes trước đó
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false, // Xóa tất cả routes trước đó
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng xuất thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          children: [
            // Profile Section: Large Avatar + Name + Email
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.gray200,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.gray600,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.gray900,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _username.isEmpty ? 'Đang tải...' : _username,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl * 2),

            // Settings Section
            Text(
              'Cài đặt tài khoản',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSettingTile(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              subtitle: 'Cập nhật thông tin của bạn',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng cập nhật thông tin sẽ được bổ sung sau'),
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: 'Bảo mật',
              subtitle: 'Mật khẩu và xác thực',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng bảo mật sẽ được bổ sung sau'),
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.notifications_outlined,
              title: 'Thông báo',
              subtitle: _notificationsEnabled ? 'Đã bật' : 'Đã tắt',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Account Section
            Text(
              'Tài khoản',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Trợ giúp & Hỗ trợ',
              subtitle: 'Câu hỏi thường gặp',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'Về ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    title: const Text(
                      'Về ứng dụng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    content: const Text(
                      'Expense Tracker\nPhiên bản 1.0.0',
                      style: TextStyle(
                        color: AppColors.gray700,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.logout,
              title: 'Đăng xuất',
              subtitle: 'Thoát khỏi tài khoản',
              iconColor: AppColors.error,
              iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
              onTap: _isLoading ? null : _signOut,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    final defaultIconColor = iconColor ?? AppColors.primary;
    final defaultIconBgColor = iconBackgroundColor ?? AppColors.primary.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: defaultIconBgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: defaultIconColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: defaultIconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.gray500,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.gray400,
        ),
        onTap: onTap,
      ),
    );
  }

}
