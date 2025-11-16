import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Profile Header
              Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.gray200,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.gray600,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Syaiful Jamil',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'syaiful.jamil@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl * 2),
              
              // Menu Items
              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: 'Cập nhật thông tin của bạn',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Bảo mật',
                subtitle: 'Mật khẩu và xác thực',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                subtitle: 'Quản lý thông báo',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Giao diện',
                subtitle: 'Chế độ sáng',
                onTap: () {},
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Account Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: AppShadows.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Trợ giúp & Hỗ trợ',
                      subtitle: 'Câu hỏi thường gặp',
                      onTap: () {},
                      showDivider: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      subtitle: 'Phiên bản 1.0.0',
                      onTap: () {},
                      showDivider: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      subtitle: 'Thoát khỏi tài khoản',
                      onTap: () {},
                      showDivider: false,
                      textColor: AppColors.error,
                      iconColor: AppColors.error,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusMD,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: AppIconSizes.md,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: textColor ?? AppColors.gray900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.gray200,
          ),
      ],
    );
  }
}

