import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/add_budget.dart';
import 'package:expenses/presentation/screens/budget_detail.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/core/supabase_flutter.dart';

/// Màn hình quản lý ngân sách (Budget).
///
/// Hiển thị danh sách các ngân sách đã đặt cho danh mục hoặc hũ,
/// cho phép tạo mới, xem chi tiết và quản lý ngân sách.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  int _selectedTab = 0; // 0: Tất cả, 1: Danh mục, 2: Hũ
  List<Map<String, dynamic>> _allBudgets = [];
  bool _isLoading = true;

  final _getCurrentUser = GetCurrentUser(DI.authRepository);

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _getCurrentUser();
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load budgets từ Supabase
      final budgetsRes = await SupabaseConfig.client
          .from('budgets')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      // Load categories và jars để lấy thông tin
      final categoriesRes = await SupabaseConfig.client
          .from('categories')
          .select('id, name, icon, color')
          .eq('user_id', user.id);

      final jarsRes = await SupabaseConfig.client
          .from('jars')
          .select('id, name')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: true);

      final categories = Map<String, Map<String, dynamic>>.fromEntries(
        (categoriesRes as List).map((c) => MapEntry(
          c['id'] as String,
          {
            'name': c['name'] as String? ?? '',
            'icon': c['icon'] as String?,
            'color': c['color'] as String?,
          },
        )),
      );

      // Màu cho jars (giống như trong add_budget.dart và home screen)
      final jarColors = <Color>[
        AppColors.error,
        AppColors.info,
        AppColors.warning,
        AppColors.primary,
        AppColors.success,
        AppColors.secondary,
      ];

      final jars = Map<String, Map<String, dynamic>>.fromEntries(
        (jarsRes as List).asMap().entries.map((entry) {
          final index = entry.key;
          final j = entry.value;
          return MapEntry(
            j['id'] as String,
            {
              'name': j['name'] as String? ?? '',
              'color': jarColors[index % jarColors.length],
            },
          );
        }),
      );

      // Map budgets data
      final budgets = (budgetsRes as List).map((b) {
        final categoryId = b['category_id'] as String?;
        final jarId = b['jar_id'] as String?;
        final category = categoryId != null ? categories[categoryId] : null;
        final jar = jarId != null ? jars[jarId] : null;

        // Parse color
        Color? color;
        IconData? icon;
        String name = '';

        if (category != null) {
          name = category['name'] as String;
          final categoryIcon = category['icon'] as String?;
          final categoryColor = category['color'] as String?;
          
          // Luôn ưu tiên lấy từ default categories trước (để đảm bảo icon/color đúng)
          final defaultCategory = _getDefaultCategoryByName(name);
          if (defaultCategory != null) {
            icon = defaultCategory['icon'] as IconData;
            color = defaultCategory['color'] as Color;
          } else if (categoryIcon != null && categoryColor != null) {
            // Nếu không có trong default, dùng từ database
            try {
              final colorStr = categoryColor;
              color = Color(
                int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000,
              );
            } catch (_) {
              color = AppColors.gray500;
            }
            icon = _getIconFromString(categoryIcon);
          } else {
            // Fallback cuối cùng
            icon = Icons.category;
            color = AppColors.gray500;
          }
        } else if (jar != null) {
          name = jar['name'] as String;
          color = jar['color'] as Color? ?? AppColors.primary;
          icon = Icons.savings_outlined;
        }

        return {
          'id': b['id'] as String,
          'name': name,
          'type': categoryId != null ? 'category' : 'jar',
          'categoryId': categoryId,
          'jarId': jarId,
          'limit': (b['limit_amount'] as num?)?.toDouble() ?? 0.0,
          'spent': (b['spent_amount'] as num?)?.toDouble() ?? 0.0,
          'period': b['period'] as String? ?? 'MONTHLY',
          'startDate': b['start_date'] as String?,
          'endDate': b['end_date'] as String?,
          'isActive': b['is_active'] as bool? ?? true,
          'icon': icon ?? Icons.category,
          'color': color ?? AppColors.gray500,
        };
      }).toList();

      setState(() {
        _allBudgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Lấy default category theo tên (fallback khi không có trong database)
  Map<String, dynamic>? _getDefaultCategoryByName(String name) {
    final defaultCategories = _getDefaultExpenseCategories();
    // Normalize tên: lowercase, trim, loại bỏ dấu câu
    final normalizedName = name.toLowerCase().trim();
    return defaultCategories[normalizedName];
  }

  /// Map các default categories với icon và color
  Map<String, Map<String, dynamic>> _getDefaultExpenseCategories() {
    return {
      'chợ, siêu thị': {
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFFFB74D), // Orange
      },
      'ăn uống': {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFFFE651), // Vàng
      },
      'di chuyển': {
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF42A5F5), // Blue
      },
      'mua sắm': {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFEC407A), // Pink đậm
      },
      'giải trí': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFFAB47BC), // Purple
      },
      'làm đẹp': {
        'icon': Icons.brush_outlined,
        'color': const Color(0xFFE91E63), // Pink đỏ
      },
      'sức khỏe': {
        'icon': Icons.favorite_outlined,
        'color': const Color(0xFFEF5350), // Red
      },
      'từ thiện': {
        'icon': Icons.volunteer_activism_outlined,
        'color': const Color(0xFFFF7043), // Orange đỏ
      },
      'hóa đơn': {
        'icon': Icons.receipt_long_outlined,
        'color': const Color(0xFF26A69A), // Teal
      },
      'nhà cửa': {
        'icon': Icons.home_outlined,
        'color': const Color(0xFF7E57C2), // Deep purple
      },
      'người thân': {
        'icon': Icons.people_outline,
        'color': const Color(0xFFF06292), // Pink nhạt
      },
      'đầu tư': {
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF66BB6A), // Green
      },
      'học tập': {
        'icon': Icons.school_outlined,
        'color': const Color(0xFF5C6BC0), // Indigo
      },
    };
  }

  IconData _getIconFromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    switch (iconName.toLowerCase()) {
      case 'shopping_bag':
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'restaurant':
      case 'restaurant_outlined':
        return Icons.restaurant_outlined;
      case 'directions_car':
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'shopping_cart':
      case 'shopping_cart_outlined':
        return Icons.shopping_cart_outlined;
      case 'card_giftcard':
      case 'card_giftcard_outlined':
        return Icons.card_giftcard_outlined;
      case 'brush':
      case 'brush_outlined':
        return Icons.brush_outlined;
      case 'favorite':
      case 'favorite_outlined':
        return Icons.favorite_outlined;
      case 'volunteer_activism':
      case 'volunteer_activism_outlined':
        return Icons.volunteer_activism_outlined;
      case 'receipt_long':
      case 'receipt_long_outlined':
        return Icons.receipt_long_outlined;
      case 'home':
      case 'home_outlined':
        return Icons.home_outlined;
      case 'people':
      case 'people_outline':
        return Icons.people_outline;
      case 'account_balance_wallet':
      case 'account_balance_wallet_outlined':
        return Icons.account_balance_wallet_outlined;
      case 'school':
      case 'school_outlined':
        return Icons.school_outlined;
      case 'savings':
      case 'savings_outlined':
        return Icons.savings_outlined;
      default:
        return Icons.category;
    }
  }

  List<Map<String, dynamic>> get _filteredBudgets {
    if (_selectedTab == 0) return _allBudgets;
    if (_selectedTab == 1) {
      return _allBudgets.where((b) => b['type'] == 'category').toList();
    }
    return _allBudgets.where((b) => b['type'] == 'jar').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý ngân sách',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Theo dõi và quản lý ngân sách cho từng danh mục hoặc hũ tiết kiệm.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('Tất cả', 0),
                    ),
                    Expanded(
                      child: _buildTabButton('Danh mục', 1),
                    ),
                    Expanded(
                      child: _buildTabButton('Hũ', 2),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Budget list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBudgets.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadBudgets,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            itemCount: _filteredBudgets.length,
                            itemBuilder: (context, index) {
                              return _BudgetCard(
                                budget: _filteredBudgets[index],
                                onTap: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BudgetDetailScreen(
                                        budget: _filteredBudgets[index],
                                      ),
                                    ),
                                  );
                                  // Refresh nếu budget đã bị xóa
                                  if (result == true) {
                                    _loadBudgets();
                                  }
                                },
                              );
                            },
                          ),
                        ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddBudgetScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadBudgets();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo ngân sách mới'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.gray900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.gray900 : AppColors.gray400,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _selectedTab == 0
                  ? 'Chưa có ngân sách nào'
                  : _selectedTab == 1
                      ? 'Chưa có ngân sách theo danh mục'
                      : 'Chưa có ngân sách theo hũ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tạo ngân sách để theo dõi chi tiêu hiệu quả hơn',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Map<String, dynamic> budget;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.budget,
    required this.onTap,
  });

  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toStringAsFixed(0)} ₫';
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'MONTHLY':
        return 'Hàng tháng';
      case 'WEEKLY':
        return 'Hàng tuần';
      case 'YEARLY':
        return 'Hàng năm';
      default:
        return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    final limit = budget['limit'] as num;
    final spent = budget['spent'] as num;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;
    final remaining = (limit - spent).clamp(0, limit);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.gray200),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Name + Type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (budget['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    budget['icon'] as IconData,
                    color: budget['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: budget['type'] == 'category'
                                  ? AppColors.primaryLight
                                  : AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              budget['type'] == 'category' ? 'Danh mục' : 'Hũ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: budget['type'] == 'category'
                                        ? AppColors.gray900
                                        : AppColors.info,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _getPeriodLabel(budget['period'] as String),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray500,
                                  fontSize: 11,
                                ),
                          ),
                        ],
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
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã chi: ${_formatCurrency(spent)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Giới hạn: ${_formatCurrency(limit)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.progressBar),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOverBudget
                          ? 'Vượt ngân sách: ${_formatCurrency(spent - limit)}'
                          : 'Còn lại: ${_formatCurrency(remaining)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isOverBudget ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
