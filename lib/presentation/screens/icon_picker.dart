import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class IconPickerScreen extends StatefulWidget {
  const IconPickerScreen({super.key});

  @override
  State<IconPickerScreen> createState() => _IconPickerScreenState();
}

class _IconPickerScreenState extends State<IconPickerScreen> {
  String? _selectedIcon;

  // Danh sách icons với màu sắc
  final List<IconOption> _icons = [
    // Common icons
    IconOption(icon: Icons.restaurant, name: 'restaurant', color: AppColors.warning),
    IconOption(icon: Icons.shopping_cart, name: 'shopping_cart', color: AppColors.warning),
    IconOption(icon: Icons.directions_car, name: 'directions_car', color: AppColors.info),
    IconOption(icon: Icons.home, name: 'home', color: AppColors.info),
    IconOption(icon: Icons.school, name: 'school', color: AppColors.success),
    IconOption(icon: Icons.favorite, name: 'favorite', color: AppColors.error),
    IconOption(icon: Icons.movie, name: 'movie', color: AppColors.error),
    IconOption(icon: Icons.account_balance_wallet, name: 'account_balance_wallet', color: AppColors.success),
    IconOption(icon: Icons.work, name: 'work', color: AppColors.info),
    IconOption(icon: Icons.savings, name: 'savings', color: AppColors.success),
    IconOption(icon: Icons.trending_up, name: 'trending_up', color: AppColors.success),
    IconOption(icon: Icons.trending_down, name: 'trending_down', color: AppColors.error),
    IconOption(icon: Icons.local_gas_station, name: 'local_gas_station', color: AppColors.error),
    IconOption(icon: Icons.coffee, name: 'coffee', color: AppColors.warning),
    IconOption(icon: Icons.shopping_basket, name: 'shopping_basket', color: AppColors.warning),
    IconOption(icon: Icons.receipt, name: 'receipt', color: AppColors.success),
    IconOption(icon: Icons.phone, name: 'phone', color: AppColors.info),
    IconOption(icon: Icons.wifi, name: 'wifi', color: AppColors.info),
    IconOption(icon: Icons.electrical_services, name: 'electrical_services', color: AppColors.warning),
    IconOption(icon: Icons.water_drop, name: 'water_drop', color: AppColors.info),
    IconOption(icon: Icons.fitness_center, name: 'fitness_center', color: AppColors.error),
    IconOption(icon: Icons.local_hospital, name: 'local_hospital', color: AppColors.error),
    IconOption(icon: Icons.card_giftcard, name: 'card_giftcard', color: AppColors.warning),
    IconOption(icon: Icons.flight, name: 'flight', color: AppColors.info),
    IconOption(icon: Icons.hotel, name: 'hotel', color: AppColors.info),
    IconOption(icon: Icons.book, name: 'book', color: AppColors.success),
    IconOption(icon: Icons.sports_basketball, name: 'sports_basketball', color: AppColors.warning),
    IconOption(icon: Icons.checkroom, name: 'checkroom', color: AppColors.info),
    IconOption(icon: Icons.restaurant_menu, name: 'restaurant_menu', color: AppColors.warning),
    IconOption(icon: Icons.school_outlined, name: 'school_outlined', color: AppColors.success),
    IconOption(icon: Icons.local_parking, name: 'local_parking', color: AppColors.info),
    IconOption(icon: Icons.medication, name: 'medication', color: AppColors.error),
    IconOption(icon: Icons.pets, name: 'pets', color: AppColors.error),
    IconOption(icon: Icons.emoji_events, name: 'emoji_events', color: AppColors.warning),
    IconOption(icon: Icons.store, name: 'store', color: AppColors.info),
    IconOption(icon: Icons.account_balance, name: 'account_balance', color: AppColors.info),
    IconOption(icon: Icons.volunteer_activism, name: 'volunteer_activism', color: AppColors.error),
    IconOption(icon: Icons.family_restroom, name: 'family_restroom', color: AppColors.error),
    IconOption(icon: Icons.face, name: 'face', color: AppColors.error),
    IconOption(icon: Icons.people, name: 'people', color: AppColors.warning),
    IconOption(icon: Icons.restaurant_menu, name: 'restaurant_menu_alt', color: AppColors.warning),
    IconOption(icon: Icons.attach_money, name: 'attach_money', color: AppColors.success),
    IconOption(icon: Icons.payment, name: 'payment', color: AppColors.info),
    IconOption(icon: Icons.credit_card, name: 'credit_card', color: AppColors.info),
  ];

  // Icons đang được sử dụng (faded)
  final List<IconOption> _usedIcons = [
    IconOption(icon: Icons.restaurant, name: 'used_restaurant', color: AppColors.gray400),
    IconOption(icon: Icons.receipt, name: 'used_receipt', color: AppColors.gray400),
    IconOption(icon: Icons.book, name: 'used_book', color: AppColors.gray400),
    IconOption(icon: Icons.favorite, name: 'used_favorite', color: AppColors.gray400),
    IconOption(icon: Icons.account_balance_wallet, name: 'used_wallet', color: AppColors.gray400),
    IconOption(icon: Icons.shopping_cart, name: 'used_cart', color: AppColors.gray400),
    IconOption(icon: Icons.movie, name: 'used_movie', color: AppColors.gray400),
    IconOption(icon: Icons.face, name: 'used_face', color: AppColors.gray400),
    IconOption(icon: Icons.home, name: 'used_home', color: AppColors.gray400),
    IconOption(icon: Icons.home_work, name: 'used_home_work', color: AppColors.gray400),
    IconOption(icon: Icons.help_outline, name: 'used_help', color: AppColors.gray400),
    IconOption(icon: Icons.trending_up, name: 'used_trending', color: AppColors.gray400),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn biểu tượng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Icons Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Icons
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final iconOption = _icons[index];
                      final isSelected = _selectedIcon == iconOption.name;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconOption.name;
                          });
                          Navigator.pop(context, {
                            'icon': iconOption.name,
                            'color': iconOption.color,
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? iconOption.color.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: AppRadius.radiusMD,
                            border: isSelected
                                ? Border.all(color: iconOption.color, width: 2)
                                : Border.all(color: AppColors.gray200),
                          ),
                          child: Icon(
                            iconOption.icon,
                            color: iconOption.color,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl * 2),

                  // Used Icons Section
                  Text(
                    'Biểu tượng đang dùng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1,
                    ),
                    itemCount: _usedIcons.length,
                    itemBuilder: (context, index) {
                      final iconOption = _usedIcons[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: AppRadius.radiusMD,
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Icon(
                          iconOption.icon,
                          color: AppColors.gray400,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconOption {
  final IconData icon;
  final String name;
  final Color color;

  IconOption({
    required this.icon,
    required this.name,
    required this.color,
  });
}

