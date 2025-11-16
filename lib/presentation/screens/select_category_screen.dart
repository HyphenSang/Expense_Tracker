import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/create_category_screen.dart';

class SelectCategoryScreen extends StatefulWidget {
  final String transactionType; // 'EXPENSE' or 'INCOME'

  const SelectCategoryScreen({
    super.key,
    required this.transactionType,
  });

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;

  // Dữ liệu fake cho categories
  List<CategoryData> _getCategories() {
    if (widget.transactionType == 'EXPENSE') {
      return [
        // Chi tiêu - sinh hoạt
        CategoryData(
          id: '1',
          name: 'Chợ, siêu thị',
          icon: 'shopping_basket',
          color: AppColors.warning,
          group: 'Chi tiêu - sinh hoạt',
        ),
        CategoryData(
          id: '2',
          name: 'Ăn uống',
          icon: 'restaurant',
          color: AppColors.warning,
          group: 'Chi tiêu - sinh hoạt',
        ),
        CategoryData(
          id: '3',
          name: 'Di chuyển',
          icon: 'directions_car',
          color: AppColors.info,
          group: 'Chi tiêu - sinh hoạt',
        ),
        // Chi phí phát sinh
        CategoryData(
          id: '4',
          name: 'Mua sắm',
          icon: 'shopping_cart',
          color: AppColors.warning,
          group: 'Chi phí phát sinh',
        ),
        CategoryData(
          id: '5',
          name: 'Giải trí',
          icon: 'movie',
          color: AppColors.error,
          group: 'Chi phí phát sinh',
        ),
        CategoryData(
          id: '6',
          name: 'Làm đẹp',
          icon: 'face',
          color: AppColors.error,
          group: 'Chi phí phát sinh',
        ),
        CategoryData(
          id: '7',
          name: 'Sức khỏe',
          icon: 'favorite',
          color: AppColors.error,
          group: 'Chi phí phát sinh',
        ),
        CategoryData(
          id: '8',
          name: 'Từ thiện',
          icon: 'volunteer_activism',
          color: AppColors.error,
          group: 'Chi phí phát sinh',
        ),
        // Chi phí cố định
        CategoryData(
          id: '9',
          name: 'Hóa đơn',
          icon: 'receipt',
          color: AppColors.success,
          group: 'Chi phí cố định',
        ),
        CategoryData(
          id: '10',
          name: 'Nhà cửa',
          icon: 'home',
          color: AppColors.info,
          group: 'Chi phí cố định',
        ),
        CategoryData(
          id: '11',
          name: 'Người thân',
          icon: 'family_restroom',
          color: AppColors.error,
          group: 'Chi phí cố định',
        ),
      ];
    } else {
      return [
        CategoryData(
          id: '12',
          name: 'Lương',
          icon: 'work',
          color: AppColors.info,
          group: 'Thu nhập',
        ),
        CategoryData(
          id: '13',
          name: 'Thưởng',
          icon: 'emoji_events',
          color: AppColors.warning,
          group: 'Thu nhập',
        ),
        CategoryData(
          id: '14',
          name: 'Lợi nhuận',
          icon: 'trending_up',
          color: AppColors.success,
          group: 'Thu nhập',
        ),
        CategoryData(
          id: '15',
          name: 'Kinh doanh',
          icon: 'store',
          color: AppColors.info,
          group: 'Thu nhập',
        ),
        CategoryData(
          id: '16',
          name: 'Trợ cấp',
          icon: 'account_balance_wallet',
          color: AppColors.error,
          group: 'Thu nhập',
        ),
        CategoryData(
          id: '17',
          name: 'Thu hồi nợ',
          icon: 'account_balance',
          color: AppColors.warning,
          group: 'Thu nhập',
        ),
      ];
    }
  }

  List<CategoryData> get _filteredCategories {
    final categories = _getCategories();
    if (_searchController.text.isEmpty) {
      return categories;
    }
    return categories
        .where((cat) =>
            cat.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  Map<String, List<CategoryData>> get _groupedCategories {
    final grouped = <String, List<CategoryData>>{};
    for (var category in _filteredCategories) {
      if (!grouped.containsKey(category.group)) {
        grouped[category.group] = [];
      }
      grouped[category.group]!.add(category);
    }
    return grouped;
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'shopping_basket': Icons.shopping_basket,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
      'face': Icons.face,
      'favorite': Icons.favorite,
      'volunteer_activism': Icons.volunteer_activism,
      'receipt': Icons.receipt,
      'home': Icons.home,
      'family_restroom': Icons.family_restroom,
      'work': Icons.work,
      'emoji_events': Icons.emoji_events,
      'trending_up': Icons.trending_up,
      'store': Icons.store,
      'account_balance_wallet': Icons.account_balance_wallet,
      'account_balance': Icons.account_balance,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _getGroupColor(String group) {
    if (group.contains('sinh hoạt')) return AppColors.warning;
    if (group.contains('phát sinh')) return AppColors.warning;
    if (group.contains('cố định')) return AppColors.info;
    return AppColors.success;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedCategories;
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
                  'Chọn danh mục',
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

          // Search and Create
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.gray100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMD,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCategoryScreen(
                          transactionType: widget.transactionType,
                        ),
                      ),
                    );
                    if (result != null) {
                      Navigator.pop(context, result);
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.gray900,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Categories List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final groupName = grouped.keys.elementAt(index);
                final categories = grouped[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _getGroupColor(groupName).withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt,
                            size: 16,
                            color: _getGroupColor(groupName),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            groupName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getGroupColor(groupName),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Categories Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, idx) {
                        final category = categories[idx];
                        final isSelected = _selectedCategoryId == category.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                            Navigator.pop(context, {
                              'name': category.name,
                              'icon': category.icon,
                              'color': category.color,
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category.color.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: AppRadius.radiusMD,
                              border: isSelected
                                  ? Border.all(color: category.color, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconData(category.icon),
                                    color: category.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  category.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.gray900,
                                        fontSize: 11,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    if (index < grouped.length - 1)
                      const SizedBox(height: AppSpacing.xl),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryData {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final String group;

  CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.group,
  });
}

