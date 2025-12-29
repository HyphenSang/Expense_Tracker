import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/add_budget.dart';
import 'package:expenses/presentation/screens/budget_detail.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/service/budget_checker.dart';

/// Màn hình quản lý ngân sách (Budget).
///
/// Hiển thị danh sách các ngân sách đã đặt cho từng danh mục,
/// cho phép tạo mới, xem chi tiết và quản lý ngân sách.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  int _selectedTimeTab = 0; // 0: Đang hoạt động, 1: Đã kết thúc
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

      // Tự động pause các budgets strict mode đã vượt 100%
      await BudgetCheckerService.autoPauseOverBudgetStrictBudgets(user.id);

      // Load budgets từ Supabase - chỉ lấy budgets theo danh mục (có category_id, không có jar_id)
      final budgetsRes = await SupabaseConfig.client
          .from('budgets')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .not('category_id', 'is', null)
          .order('created_at', ascending: false);

      // Load categories để lấy thông tin
      final categoriesRes = await SupabaseConfig.client
          .from('categories')
          .select('id, name, icon, color')
          .eq('user_id', user.id);

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

      final now = DateTime.now();

      // Map budgets data
      final budgets = (budgetsRes as List).map((b) {
        final categoryId = b['category_id'] as String?;
        final category = categoryId != null ? categories[categoryId] : null;

        // Parse color và icon
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
        }

        final startDate = b['start_date'] != null
            ? DateTime.parse(b['start_date'] as String)
            : null;
        final endDate = b['end_date'] != null
            ? DateTime.parse(b['end_date'] as String)
            : null;
        final limit = (b['limit_amount'] as num?)?.toDouble() ?? 0.0;
        final spent = (b['spent_amount'] as num?)?.toDouble() ?? 0.0;

        // Xác định trạng thái budget
        bool isActive = false; // Đang diễn ra
        bool isCompleted = false; // Đã hết thời gian
        bool isSuccess = false; // Thành công (spent <= limit và đã hết thời gian)
        bool isFailed = false; // Thất bại (spent > limit và đã hết thời gian)

        // Kiểm tra cả startDate và endDate
        if (startDate != null && endDate != null) {
          // Có cả startDate và endDate
          if (now.isBefore(startDate)) {
            // Chưa bắt đầu
            isActive = false;
            isCompleted = false;
          } else if (now.isAfter(endDate)) {
            // Đã kết thúc
            isCompleted = true;
            isSuccess = spent <= limit;
            isFailed = spent > limit;
          } else {
            // Đang diễn ra (now >= startDate && now <= endDate)
            isActive = true;
          }
        } else if (startDate != null) {
          // Chỉ có startDate
          if (now.isBefore(startDate)) {
            isActive = false;
          } else {
            isActive = true;
          }
        } else if (endDate != null) {
          // Chỉ có endDate
          if (now.isAfter(endDate)) {
            isCompleted = true;
            isSuccess = spent <= limit;
            isFailed = spent > limit;
          } else {
            isActive = true;
          }
        } else {
          // Không có startDate và endDate
          isActive = true;
        }

        return {
          'id': b['id'] as String,
          'name': name,
          'categoryId': categoryId,
          'categoryName': name, // Thêm categoryName để dùng khi edit
          'limit': limit,
          'spent': spent,
          'period': b['period'] as String? ?? 'MONTHLY',
          'startDate': b['start_date'] as String?,
          'endDate': b['end_date'] as String?,
          'isActive': b['is_active'] as bool? ?? true,
          'createdAt': b['created_at'] as String?,
          'budgetMode': b['budget_mode'] as String? ?? 'reminder', // Thêm budgetMode
          'isPaused': b['is_paused'] as bool? ?? false, // Thêm isPaused
          'icon': icon ?? Icons.category,
          'color': color ?? AppColors.gray500,
          'isActiveTime': isActive,
          'isCompleted': isCompleted,
          'isSuccess': isSuccess,
          'isFailed': isFailed,
        };
      }).toList();

      // Lọc để chỉ giữ lại 1 budget đang diễn ra cho mỗi category
      // Nếu có nhiều budgets cùng category trong cùng thời gian, chọn budget mới nhất (created_at mới nhất)
      final Map<String, Map<String, dynamic>> activeBudgetsByCategory = {};
      final List<Map<String, dynamic>> completedBudgets = [];
      
      for (final budget in budgets) {
        final categoryId = budget['categoryId'] as String?;
        if (categoryId == null) continue;
        
        final isActiveTime = budget['isActiveTime'] as bool? ?? false;
        final isCompleted = budget['isCompleted'] as bool? ?? false;
        
        if (isActiveTime) {
          // Budget đang diễn ra - chỉ giữ 1 budget cho mỗi category
          if (!activeBudgetsByCategory.containsKey(categoryId)) {
            activeBudgetsByCategory[categoryId] = budget;
          } else {
            // Nếu đã có budget cho category này, so sánh created_at để chọn budget mới nhất
            final existing = activeBudgetsByCategory[categoryId]!;
            final existingCreatedAt = existing['createdAt'] as String?;
            final currentCreatedAt = budget['createdAt'] as String?;
            
            // Ưu tiên budget có created_at mới hơn (tạo sau)
            if (currentCreatedAt != null && existingCreatedAt != null) {
              final currentCreated = DateTime.parse(currentCreatedAt);
              final existingCreated = DateTime.parse(existingCreatedAt);
              if (currentCreated.isAfter(existingCreated)) {
                // Budget hiện tại được tạo sau -> chọn budget hiện tại
                activeBudgetsByCategory[categoryId] = budget;
              }
            } else if (currentCreatedAt != null) {
              // Budget hiện tại có created_at, budget cũ không có -> chọn budget hiện tại
              activeBudgetsByCategory[categoryId] = budget;
            }
            // Nếu budget cũ có created_at và budget hiện tại không có, giữ nguyên budget cũ
          }
        } else if (isCompleted) {
          // Budget đã kết thúc - giữ tất cả để hiển thị trong tab "Đã kết thúc"
          completedBudgets.add(budget);
        }
      }
      
      // Kết hợp budgets đang diễn ra và đã kết thúc
      final filteredBudgets = [
        ...activeBudgetsByCategory.values,
        ...completedBudgets,
      ];

      setState(() {
        _allBudgets = filteredBudgets;
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
    // Lọc theo tab thời gian
    if (_selectedTimeTab == 0) {
      // Đang hoạt động
      return _allBudgets.where((b) => b['isActiveTime'] == true).toList();
    } else {
      // Đã kết thúc
      return _allBudgets.where((b) => b['isCompleted'] == true).toList();
    }
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
                    'Theo dõi và quản lý ngân sách cho từng danh mục chi tiêu.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
            ),

            // Filter - Đang hoạt động / Đã kết thúc
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
                      child: _buildTimeTabButton('Đang hoạt động', 0),
                    ),
                    Expanded(
                      child: _buildTimeTabButton('Đã kết thúc', 1),
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

  Widget _buildTimeTabButton(String label, int index) {
    final isSelected = _selectedTimeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeTab = index;
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
              'Chưa có ngân sách nào',
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
    final isFailed = budget['isFailed'] == true; // Budget đã qua và thất bại

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isFailed 
              ? AppColors.error.withValues(alpha: 0.05) // Màu đỏ nhạt cho thất bại
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isFailed 
                ? AppColors.error.withValues(alpha: 0.3) // Viền đỏ nhạt cho thất bại
                : AppColors.gray200,
            width: isFailed ? 1.5 : 1,
          ),
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
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Danh mục',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.gray900,
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
                          // Hiển thị trạng thái
                          // Nếu budget đã bị pause (strict mode vượt 100%)
                          if (budget['isPaused'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Đã tạm dừng',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ]
                          // Nếu budget đã kết thúc
                          else if (budget['isCompleted'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (budget['isSuccess'] == true
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                budget['isSuccess'] == true ? 'Thành công' : 'Thất bại',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: budget['isSuccess'] == true
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
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
