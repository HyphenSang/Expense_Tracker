import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/category.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/presentation/screens/budget_detail.dart';

/// Màn hình tạo/chỉnh sửa ngân sách.
class AddBudgetScreen extends StatefulWidget {
  final Map<String, dynamic>? budgetToEdit;

  const AddBudgetScreen({super.key, this.budgetToEdit});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _selectedPeriod = 'MONTHLY'; // MONTHLY, WEEKLY, YEARLY
  String _selectedBudgetMode = 'reminder'; // reminder, warning, strict
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isCreating = false;

  // Use cases
  final _getCurrentUser = GetCurrentUser(DI.authRepository);

  bool get _isEditMode => widget.budgetToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadBudgetData();
    }
  }

  void _loadBudgetData() {
    final budget = widget.budgetToEdit!;
    // Đảm bảo lấy đúng limit_amount, không nhầm với spent_amount
    final limitValue = budget['limit'] as num?;
    if (limitValue == null) {
      throw StateError('Không thể tải dữ liệu ngân sách: thiếu limit_amount');
    }
    _limitController.text = limitValue.toString();
    _selectedCategoryId = budget['categoryId'] as String?;
    _selectedCategoryName = budget['categoryName'] as String?;
    _selectedPeriod = budget['period'] as String? ?? 'MONTHLY';
    _selectedBudgetMode = budget['budgetMode'] as String? ?? 'reminder';
    
    final startDateStr = budget['startDate'] as String?;
    if (startDateStr != null) {
      _startDate = DateTime.parse(startDateStr);
    }
    
    final endDateStr = budget['endDate'] as String?;
    if (endDateStr != null) {
      _endDate = DateTime.parse(endDateStr);
    } else {
      // Nếu không có end_date, tự động tính toán dựa trên period
      _calculateEndDate();
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final user = _getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa đăng nhập'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _CategoryPickerSheet(
        userId: user.id,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategoryId = result['id'];
        _selectedCategoryName = result['name'];
      });
    }
  }


  /// Tính toán ngày kết thúc dựa trên ngày bắt đầu và chu kỳ
  void _calculateEndDate() {
    DateTime newEndDate;
    switch (_selectedPeriod) {
      case 'WEEKLY':
        // Hàng tuần: thêm 6 ngày (tổng 7 ngày từ ngày bắt đầu)
        newEndDate = _startDate.add(const Duration(days: 6));
        break;
      case 'MONTHLY':
        // Hàng tháng: thêm 1 tháng, trừ 1 ngày
        // Ví dụ: 01/01 -> 31/01 (30 ngày)
        try {
          final nextMonth = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
          // Nếu ngày không hợp lệ (ví dụ: 31/02), lấy ngày cuối của tháng
          if (nextMonth.month != ((_startDate.month % 12) + 1)) {
            newEndDate = DateTime(_startDate.year, _startDate.month + 1, 0);
          } else {
            newEndDate = nextMonth.subtract(const Duration(days: 1));
          }
        } catch (e) {
          // Fallback: lấy ngày cuối của tháng
          newEndDate = DateTime(_startDate.year, _startDate.month + 1, 0);
        }
        break;
      case 'YEARLY':
        // Hàng năm: thêm 1 năm, trừ 1 ngày
        // Ví dụ: 01/01/2024 -> 31/12/2024 (365 ngày)
        try {
          final nextYear = DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
          // Xử lý năm nhuận (29/02)
          if (nextYear.month != _startDate.month || nextYear.day != _startDate.day) {
            newEndDate = DateTime(_startDate.year + 1, _startDate.month, 0);
          } else {
            newEndDate = nextYear.subtract(const Duration(days: 1));
          }
        } catch (e) {
          // Fallback: lấy ngày cuối của tháng trước đó trong năm sau
          newEndDate = DateTime(_startDate.year + 1, _startDate.month, 0);
        }
        break;
      default:
        return;
    }
      setState(() {
      _endDate = newEndDate;
      });
  }

  Future<void> _pickStartDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        _startDate = result;
      });
      // Tự động tính toán ngày kết thúc khi thay đổi ngày bắt đầu
      _calculateEndDate();
    }
  }

  Future<void> _pickEndDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        _endDate = result;
      });
    }
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final limit = int.tryParse(_limitController.text) ?? 0;
      if (limit <= 0) {
        throw StateError('Số tiền giới hạn phải lớn hơn 0');
      }

      final user = _getCurrentUser();
      if (user == null) {
        throw StateError('Chưa đăng nhập');
      }

      // Tạo budget trong Supabase
      final budgetData = {
        'user_id': user.id,
        'period': _selectedPeriod,
        'limit_amount': limit,
        'spent_amount': 0,
        'start_date': _startDate.toIso8601String().split('T')[0],
        'is_active': true,
        'budget_mode': _selectedBudgetMode, // reminder, warning, strict
      };

      // Thêm category_id
        String? finalCategoryId = _selectedCategoryId;
        
        // Nếu là default category, cần tạo category trong database trước
        if (_selectedCategoryId!.startsWith('default_')) {
          final getOrCreateCategory = GetOrCreateCategory(DI.categoryRepository, user.id);
          final category = await getOrCreateCategory(
            categoryName: _selectedCategoryName!,
            type: 'EXPENSE',
          );
          finalCategoryId = category.id;
        }
        
        budgetData['category_id'] = finalCategoryId as Object;

      // Thêm end_date nếu có
      if (_endDate != null) {
        budgetData['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }

      // Chỉ kiểm tra overlap khi tạo mới, không check khi edit
      if (!_isEditMode) {
        final overlappingBudget = await _checkOverlappingBudget(
          userId: user.id,
          categoryId: finalCategoryId!,
          newStartDate: _startDate,
          newEndDate: _endDate,
        );

        if (overlappingBudget != null) {
          // Hiển thị dialog cảnh báo với budget trùng lặp
          final action = await _showOverlappingBudgetDialog(context, overlappingBudget);
          
          if (action == 'cancel') {
            setState(() {
              _isCreating = false;
            });
            return;
          } else if (action == 'view_detail') {
            // User muốn xem chi tiết, không tạo budget mới
            setState(() {
              _isCreating = false;
            });
            return;
          }
          // Nếu action == 'continue', vẫn tạo budget mới
        }
      }

      // Tạo hoặc cập nhật budget trong Supabase
      if (_isEditMode) {
        final budgetId = widget.budgetToEdit!['id'] as String;
        // Không cập nhật spent_amount, chỉ cập nhật các field khác
        final updateData = {
          'period': budgetData['period'],
          'limit_amount': budgetData['limit_amount'],
          'start_date': budgetData['start_date'],
          'end_date': budgetData['end_date'],
          'category_id': budgetData['category_id'],
          'budget_mode': budgetData['budget_mode'],
          'updated_at': DateTime.now().toIso8601String(),
        };
        await DI.budgetRepository.updateBudget(budgetId, updateData);
      } else {
        // Tạo budget mới
        await SupabaseConfig.client.from('budgets').insert(budgetData);
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Đã cập nhật ngân sách thành công' : 'Đã tạo ngân sách thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Không thể cập nhật ngân sách: $e' : 'Không thể tạo ngân sách: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  /// Kiểm tra xem có budget trùng lặp không (cùng category, cùng khoảng thời gian)
  Future<Map<String, dynamic>?> _checkOverlappingBudget({
    required String userId,
    required String categoryId,
    required DateTime newStartDate,
    DateTime? newEndDate,
  }) async {
    try {
      // Lấy tất cả budgets active của user có category_id này
      final existingBudgets = await SupabaseConfig.client
          .from('budgets')
          .select('*')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('is_active', true);

      final now = DateTime.now();

      for (final budget in existingBudgets as List) {
        final oldStartDateStr = budget['start_date'] as String;
        final oldEndDateStr = budget['end_date'] as String?;
        final oldStartDate = DateTime.parse(oldStartDateStr);
        final oldEndDate = oldEndDateStr != null ? DateTime.parse(oldEndDateStr) : null;

        // Kiểm tra xem budget cũ có đang diễn ra không (chưa hết thời gian)
        final isOldActive = oldEndDate == null || now.isBefore(oldEndDate) || now.isAtSameMomentAs(oldEndDate);

        if (!isOldActive) continue; // Bỏ qua budget đã hết thời gian

        // Kiểm tra overlap giữa 2 khoảng thời gian
        // Overlap nếu: newStartDate <= oldEndDate VÀ (newEndDate == null HOẶC newEndDate >= oldStartDate)
        // Hoặc: newEndDate == null (không giới hạn) và newStartDate <= oldEndDate
        // Hoặc: oldEndDate == null (không giới hạn) và newEndDate >= oldStartDate
        bool hasOverlap = false;
        
        if (newEndDate == null && oldEndDate == null) {
          // Cả 2 đều không giới hạn -> luôn overlap
          hasOverlap = true;
        } else if (newEndDate == null) {
          // Budget mới không giới hạn -> overlap nếu newStartDate <= oldEndDate
          if (oldEndDate != null) {
            hasOverlap = newStartDate.isBefore(oldEndDate) || newStartDate.isAtSameMomentAs(oldEndDate);
          }
        } else if (oldEndDate == null) {
          // Budget cũ không giới hạn -> overlap nếu newEndDate >= oldStartDate
          hasOverlap = newEndDate.isAfter(oldStartDate) || newEndDate.isAtSameMomentAs(oldStartDate);
        } else {
          // Cả 2 đều có endDate -> overlap nếu newStartDate <= oldEndDate VÀ newEndDate >= oldStartDate
          hasOverlap = (newStartDate.isBefore(oldEndDate) || newStartDate.isAtSameMomentAs(oldEndDate)) &&
              (newEndDate.isAfter(oldStartDate) || newEndDate.isAtSameMomentAs(oldStartDate));
        }

        if (hasOverlap) {
          // Lấy thông tin category để hiển thị
          final categoryRes = await SupabaseConfig.client
              .from('categories')
              .select('name, icon, color')
              .eq('id', categoryId)
              .single();

          return {
            'id': budget['id'] as String,
            'categoryName': categoryRes['name'] as String? ?? _selectedCategoryName ?? '',
            'limitAmount': budget['limit_amount'] as num? ?? 0,
            'spentAmount': budget['spent_amount'] as num? ?? 0,
            'startDate': oldStartDateStr,
            'endDate': oldEndDateStr,
            'period': budget['period'] as String? ?? 'MONTHLY',
          };
        }
      }

      return null;
    } catch (e) {
      // Nếu có lỗi, cho phép tạo budget (không block)
      return null;
    }
  }

  /// Hiển thị dialog cảnh báo budget trùng lặp
  /// Returns: 'cancel', 'view_detail', hoặc 'continue'
  Future<String> _showOverlappingBudgetDialog(
    BuildContext context,
    Map<String, dynamic> overlappingBudget,
  ) async {
    final theme = Theme.of(context);
    final categoryName = overlappingBudget['categoryName'] as String;
    final limitAmount = overlappingBudget['limitAmount'] as num;
    final spentAmount = overlappingBudget['spentAmount'] as num;
    final startDateStr = overlappingBudget['startDate'] as String;
    final endDateStr = overlappingBudget['endDate'] as String?;
    final period = overlappingBudget['period'] as String;
    final budgetId = overlappingBudget['id'] as String;

    String _formatCurrency(num amount) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(0)}K ₫';
      }
      return '${amount.toStringAsFixed(0)} ₫';
    }

    String _formatDate(String dateStr) {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Ngân sách đã tồn tại',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.gray600, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop('cancel'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
              'Danh mục "$categoryName" đã có ngân sách đang diễn ra trong khoảng thời gian này.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
            const SizedBox(height: AppSpacing.md),
            // Hiển thị thông tin budget trùng lặp với hiệu ứng nổi bật
                Container(
              padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Ngân sách hiện tại:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Hạn mức: ${_formatCurrency(limitAmount)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Đã chi: ${_formatCurrency(spentAmount)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Thời gian: ${_formatDate(startDateStr)} - ${endDateStr != null ? _formatDate(endDateStr) : "Không giới hạn"}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Chu kỳ: ${_getPeriodLabel(period)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bạn có muốn xem chi tiết ngân sách này để chỉnh sửa hoặc xóa không?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop('view_detail'); // Đóng dialog này
              // Navigate đến budget detail
              final budgetData = await _loadBudgetDetail(budgetId);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BudgetDetailScreen(budget: budgetData),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
            ),
            child: const Text('Xem chi tiết'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('continue'), // Cho phép tiếp tục tạo
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );

    return result ?? 'cancel';
  }

  /// Load budget detail để hiển thị
  Future<Map<String, dynamic>> _loadBudgetDetail(String budgetId) async {
    final user = _getCurrentUser();
    if (user == null) throw StateError('Chưa đăng nhập');

    // Load budget
    final budgetRes = await SupabaseConfig.client
        .from('budgets')
        .select('*')
        .eq('id', budgetId)
        .single();

    // Load category
    final categoryId = budgetRes['category_id'] as String?;
    if (categoryId == null) throw StateError('Budget không có category');

    final categoryRes = await SupabaseConfig.client
        .from('categories')
        .select('name, icon, color')
        .eq('id', categoryId)
        .single();

    // Parse color và icon
    Color? color;
    IconData? icon;
    final categoryName = categoryRes['name'] as String? ?? '';
    final categoryIcon = categoryRes['icon'] as String?;
    final categoryColor = categoryRes['color'] as String?;

    // Lấy default category nếu có
    final defaultCategories = _getDefaultExpenseCategories();
    final normalizedName = categoryName.toLowerCase().trim();
    final defaultCategory = defaultCategories[normalizedName];

    if (defaultCategory != null) {
      icon = defaultCategory['icon'] as IconData;
      color = defaultCategory['color'] as Color;
    } else if (categoryIcon != null && categoryColor != null) {
      try {
        color = Color(
          int.parse(categoryColor.replaceAll('#', ''), radix: 16) + 0xFF000000,
        );
      } catch (_) {
        color = AppColors.gray500;
      }
      icon = _getIconFromString(categoryIcon);
    } else {
      icon = Icons.category;
      color = AppColors.gray500;
    }

    return {
      'id': budgetRes['id'] as String,
      'name': categoryName,
      'categoryId': categoryId,
      'limit': (budgetRes['limit_amount'] as num?)?.toDouble() ?? 0.0,
      'spent': (budgetRes['spent_amount'] as num?)?.toDouble() ?? 0.0,
      'period': budgetRes['period'] as String? ?? 'MONTHLY',
      'startDate': budgetRes['start_date'] as String?,
      'endDate': budgetRes['end_date'] as String?,
      'isActive': budgetRes['is_active'] as bool? ?? true,
      'icon': icon,
      'color': color,
    };
  }

  Map<String, Map<String, dynamic>> _getDefaultExpenseCategories() {
    return {
      'chợ, siêu thị': {
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFFFB74D),
      },
      'ăn uống': {
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFFFE651),
      },
      'di chuyển': {
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF42A5F5),
      },
      'mua sắm': {
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFFEC407A),
      },
      'giải trí': {
        'icon': Icons.card_giftcard_outlined,
        'color': const Color(0xFFAB47BC),
      },
    };
  }

  IconData _getIconFromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;
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
      default:
        return Icons.category;
    }
  }

  Widget _buildBudgetModeCard({
    required BuildContext context,
    required String mode,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedBudgetMode == mode;

    return GestureDetector(
                          onTap: () {
                            setState(() {
          _selectedBudgetMode = mode;
                            });
                          },
                          child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                  Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                      ),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                      ),
                            child: Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: AppColors.gray300,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _limitController.text.isNotEmpty &&
        _selectedCategoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh sửa ngân sách' : 'Tạo ngân sách'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chọn danh mục
                  Text(
                  'Danh mục*',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                  onTap: _pickCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.gray300),
                      ),
                      child: Row(
                        children: [
                        const Icon(Icons.category_outlined, color: AppColors.gray700),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                            _selectedCategoryName ?? 'Chọn danh mục',
                              style: theme.textTheme.bodyMedium?.copyWith(
                              color: _selectedCategoryName == null
                                    ? AppColors.gray400
                                    : AppColors.gray900,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.gray400),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Số tiền giới hạn
                Text(
                  'Số tiền giới hạn*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _limitController,
                  decoration: InputDecoration(
                    hintText: '0 đ',
                    hintStyle: const TextStyle(color: AppColors.gray400),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.gray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền giới hạn';
                    }
                    final amount = int.tryParse(value) ?? 0;
                    if (amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Chu kỳ
                Text(
                  'Chu kỳ*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPeriod = 'WEEKLY';
                            });
                            // Tự động tính toán ngày kết thúc khi chọn chu kỳ
                            _calculateEndDate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _selectedPeriod == 'WEEKLY'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Hàng tuần',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedPeriod == 'WEEKLY'
                                    ? AppColors.gray900
                                    : AppColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPeriod = 'MONTHLY';
                            });
                            // Tự động tính toán ngày kết thúc khi chọn chu kỳ
                            _calculateEndDate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _selectedPeriod == 'MONTHLY'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Hàng tháng',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedPeriod == 'MONTHLY'
                                    ? AppColors.gray900
                                    : AppColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPeriod = 'YEARLY';
                            });
                            // Tự động tính toán ngày kết thúc khi chọn chu kỳ
                            _calculateEndDate();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _selectedPeriod == 'YEARLY'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Hàng năm',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedPeriod == 'YEARLY'
                                    ? AppColors.gray900
                                    : AppColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Chế độ ngân sách
                Text(
                  'Chế độ ngân sách',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Nhắc nhở
                _buildBudgetModeCard(
                  context: context,
                  mode: 'reminder',
                  title: 'Nhắc nhở',
                  subtitle: 'Nhẹ nhàng',
                  description: 'Cảnh báo nhẹ, vẫn cho phép thêm giao dịch',
                  icon: Icons.notifications_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                // Cảnh báo
                _buildBudgetModeCard(
                  context: context,
                  mode: 'warning',
                  title: 'Cảnh báo',
                  subtitle: 'Vừa phải',
                  description: 'Yêu cầu xác nhận và ghi lý do khi vượt 100%',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.md),
                // Nghiêm ngặt
                _buildBudgetModeCard(
                  context: context,
                  mode: 'strict',
                  title: 'Nghiêm ngặt',
                  subtitle: 'Mạnh mẽ',
                  description: 'Tự động tạm dừng khi đạt 100%, yêu cầu lý do bắt buộc',
                  icon: Icons.lock_outline,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Ngày bắt đầu
                Text(
                  'Ngày bắt đầu*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.gray700),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.gray400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Ngày kết thúc (tùy chọn)
                Text(
                  'Ngày kết thúc (tùy chọn)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.gray700),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            _endDate == null
                                ? 'Chọn ngày kết thúc'
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _endDate == null ? AppColors.gray400 : AppColors.gray900,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.gray400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl * 2),

                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid && !_isCreating ? _createBudget : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      backgroundColor: isValid && !_isCreating
                          ? AppColors.primary
                          : AppColors.gray300,
                      foregroundColor: isValid && !_isCreating
                          ? AppColors.gray900
                          : AppColors.gray500,
                      disabledBackgroundColor: AppColors.gray300,
                      disabledForegroundColor: AppColors.gray500,
                    ),
                    child: Text(
                      _isCreating 
                        ? (_isEditMode ? 'Đang cập nhật...' : 'Đang tạo...')
                        : (_isEditMode ? 'Cập nhật ngân sách' : 'Tạo ngân sách'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom sheet chọn danh mục (chỉ EXPENSE)
class _CategoryPickerSheet extends StatefulWidget {
  final String userId;

  const _CategoryPickerSheet({
    required this.userId,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<_CategoryItem> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      // Load danh mục mặc định
      final defaultCategories = _getDefaultExpenseCategories();
      
      // Load danh mục của user từ database
      final getCategories = GetCategories(DI.categoryRepository, widget.userId);
      final userCategories = await getCategories();

      // Lọc danh mục EXPENSE của user
      final userExpenseCategories = userCategories
          .where((cat) => cat.type == 'EXPENSE')
          .map((cat) {
            Color? color;
            try {
              final colorStr = cat.color ?? '#6B7280';
              color = Color(
                  int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000);
            } catch (_) {
              color = AppColors.gray500;
            }

            return _CategoryItem(
              id: cat.id,
              name: cat.name,
              icon: _getIconFromString(cat.icon),
              color: color,
              type: cat.type,
              categoryGroup: cat.categoryGroup,
            );
          })
          .toList();

      // Lọc bỏ danh mục trùng tên (ưu tiên danh mục mặc định)
      final defaultNames = defaultCategories.map((c) => c.name.toLowerCase()).toSet();
      final uniqueUserCategories = userExpenseCategories
          .where((c) => !defaultNames.contains(c.name.toLowerCase()))
          .toList();

      // Kết hợp danh mục mặc định với danh mục của user (không trùng tên)
      setState(() {
        _categories = [
          ...defaultCategories.map((cat) => _CategoryItem(
                id: 'default_${cat.name}', // ID tạm cho danh mục mặc định
                name: cat.name,
                icon: cat.icon,
                color: cat.color,
                type: cat.type,
              )),
          ...uniqueUserCategories,
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<_CategoryItem> _getDefaultExpenseCategories() {
    return [
      // Chi tiêu - sinh hoạt
      _CategoryItem(
        id: 'default_chợ_siêu_thị',
        name: 'Chợ, siêu thị',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFFFFB74D), // Orange
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_ăn_uống',
        name: 'Ăn uống',
        icon: Icons.restaurant_outlined,
        color: const Color(0xFFFFE651), // Vàng
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_di_chuyển',
        name: 'Di chuyển',
        icon: Icons.directions_car_outlined,
        color: const Color(0xFF42A5F5), // Blue
        type: 'EXPENSE',
      ),
      // Chi phí phát sinh
      _CategoryItem(
        id: 'default_mua_sắm',
        name: 'Mua sắm',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFEC407A), // Pink đậm
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_giải_trí',
        name: 'Giải trí',
        icon: Icons.card_giftcard_outlined,
        color: const Color(0xFFAB47BC), // Purple
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_làm_đẹp',
        name: 'Làm đẹp',
        icon: Icons.brush_outlined,
        color: const Color(0xFFE91E63), // Pink đỏ
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_sức_khỏe',
        name: 'Sức khỏe',
        icon: Icons.favorite_outlined,
        color: const Color(0xFFEF5350), // Red
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_từ_thiện',
        name: 'Từ thiện',
        icon: Icons.volunteer_activism_outlined,
        color: const Color(0xFFFF7043), // Orange đỏ
        type: 'EXPENSE',
      ),
      // Chi phí cố định
      _CategoryItem(
        id: 'default_hóa_đơn',
        name: 'Hóa đơn',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF26A69A), // Teal
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_nhà_cửa',
        name: 'Nhà cửa',
        icon: Icons.home_outlined,
        color: const Color(0xFF7E57C2), // Deep purple
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_người_thân',
        name: 'Người thân',
        icon: Icons.people_outline,
        color: const Color(0xFFF06292), // Pink nhạt
        type: 'EXPENSE',
      ),
      // Đầu tư - tiết kiệm
      _CategoryItem(
        id: 'default_đầu_tư',
        name: 'Đầu tư',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF66BB6A), // Green
        type: 'EXPENSE',
      ),
      _CategoryItem(
        id: 'default_học_tập',
        name: 'Học tập',
        icon: Icons.school_outlined,
        color: const Color(0xFF5C6BC0), // Indigo
        type: 'EXPENSE',
      ),
    ];
  }

  IconData _getIconFromString(String? iconName) {
    // Map icon name string to IconData - parse từ codePoint
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    
    // Parse format: "codePoint" hoặc "codePoint:fontFamily"
    try {
      if (iconName.contains(':')) {
        final parts = iconName.split(':');
        final codePoint = int.parse(parts[0]);
        final fontFamily = parts[1];
        return IconData(
          codePoint,
          fontFamily: fontFamily,
        );
      } else {
        // Chỉ có codePoint, dùng MaterialIcons mặc định
        final codePoint = int.parse(iconName);
        return IconData(
          codePoint,
          fontFamily: 'MaterialIcons',
        );
      }
    } catch (e) {
      // Nếu parse lỗi, thử map theo tên (backward compatibility)
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
        default:
          return Icons.category;
      }
    }
  }

  List<_CategoryItem> _filterCategories() {
    if (_searchQuery.isEmpty) return _categories;
    final query = _searchQuery.toLowerCase();
    return _categories
        .where((cat) => cat.name.toLowerCase().contains(query))
        .toList();
  }

  List<_CategoryItem> _getExpenseCategories() {
    // Lọc danh mục chi tiêu
    return _categories.where((c) => c.type == 'EXPENSE').toList();
  }

  List<_CategoryItem> _getGroupedCategories(String groupName) {
    final all = _getExpenseCategories();
    switch (groupName) {
      case 'Chi tiêu - sinh hoạt':
        return all.where((cat) {
          final name = cat.name.toLowerCase();
          return name.contains('chợ') ||
              name.contains('siêu thị') ||
              name.contains('ăn uống') ||
              name.contains('di chuyển');
        }).toList();
      case 'Chi phí phát sinh':
        return all.where((cat) {
          final name = cat.name.toLowerCase();
          return name.contains('mua sắm') ||
              name.contains('giải trí') ||
              name.contains('làm đẹp') ||
              name.contains('sức khỏe') ||
              name.contains('từ thiện');
        }).toList();
      case 'Chi phí cố định':
        return all.where((cat) {
          // Ưu tiên dùng categoryGroup từ database
          if (cat.categoryGroup == 'fixed') return true;
          // Fallback: dựa vào tên (backward compatibility)
          final name = cat.name.toLowerCase();
          return name.contains('hóa đơn') ||
              name.contains('nhà cửa') ||
              name.contains('người thân');
        }).toList();
      case 'Đầu tư - tiết kiệm':
        return all.where((cat) {
          // Ưu tiên dùng categoryGroup từ database
          if (cat.categoryGroup == 'investment') return true;
          // Fallback: dựa vào tên (backward compatibility)
          final name = cat.name.toLowerCase();
          return name.contains('đầu tư') || name.contains('học tập');
        }).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chọn danh mục',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Tìm kiếm danh mục',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          final filteredExpense = _filterCategories();
                          
                          if (_searchQuery.isNotEmpty && filteredExpense.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: AppColors.gray400,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Không tìm thấy danh mục nào',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Thử tìm kiếm với từ khóa khác',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.gray400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.sm),
                                // Nhóm "Chi tiêu - sinh hoạt"
                                _CategoryGroup(
                                  title: 'Chi tiêu - sinh hoạt',
                                  icon: Icons.receipt_long,
                                  color: AppColors.warning,
                                  items: _getGroupedCategories('Chi tiêu - sinh hoạt'),
                                  onTap: (category) {
                                    Navigator.of(context).pop({
                                      'id': category.id,
                                      'name': category.name,
                                    });
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                // Nhóm "Chi phí phát sinh"
                                _CategoryGroup(
                                  title: 'Chi phí phát sinh',
                                  icon: Icons.account_balance,
                                  color: const Color(0xFFFFD54F),
                                  items: _getGroupedCategories('Chi phí phát sinh'),
                                  onTap: (category) {
                                    Navigator.of(context).pop({
                                      'id': category.id,
                                      'name': category.name,
                                    });
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                // Nhóm "Chi phí cố định"
                                _CategoryGroup(
                                  title: 'Chi phí cố định',
                                  icon: Icons.account_balance,
                                  color: AppColors.info,
                                  items: _getGroupedCategories('Chi phí cố định'),
                                  onTap: (category) {
                                    Navigator.of(context).pop({
                                      'id': category.id,
                                      'name': category.name,
                                    });
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                // Nhóm "Đầu tư - tiết kiệm"
                                _CategoryGroup(
                                  title: 'Đầu tư - tiết kiệm',
                                  icon: Icons.account_balance_wallet,
                                  color: AppColors.success,
                                  items: _getGroupedCategories('Đầu tư - tiết kiệm'),
                                  onTap: (category) {
                                    Navigator.of(context).pop({
                                      'id': category.id,
                                      'name': category.name,
                                    });
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                // Các category khác
                                if (filteredExpense.any((cat) {
                                  final name = cat.name.toLowerCase();
                                  return !name.contains('chợ') &&
                                      !name.contains('siêu thị') &&
                                      !name.contains('ăn uống') &&
                                      !name.contains('di chuyển') &&
                                      !name.contains('mua sắm') &&
                                      !name.contains('giải trí') &&
                                      !name.contains('làm đẹp') &&
                                      !name.contains('sức khỏe') &&
                                      !name.contains('từ thiện') &&
                                      !name.contains('hóa đơn') &&
                                      !name.contains('nhà cửa') &&
                                      !name.contains('người thân') &&
                                      !name.contains('đầu tư') &&
                                      !name.contains('học tập');
                                }))
                                  _CategoryGroup(
                                    title: 'Khác',
                                    icon: Icons.category,
                                    color: AppColors.gray500,
                                    items: filteredExpense.where((cat) {
                                      final name = cat.name.toLowerCase();
                                      return !name.contains('chợ') &&
                                          !name.contains('siêu thị') &&
                                          !name.contains('ăn uống') &&
                                          !name.contains('di chuyển') &&
                                          !name.contains('mua sắm') &&
                                          !name.contains('giải trí') &&
                                          !name.contains('làm đẹp') &&
                                          !name.contains('sức khỏe') &&
                                          !name.contains('từ thiện') &&
                                          !name.contains('hóa đơn') &&
                                          !name.contains('nhà cửa') &&
                                          !name.contains('người thân') &&
                                          !name.contains('đầu tư') &&
                                          !name.contains('học tập');
                                    }).toList(),
                                    onTap: (category) {
                                      Navigator.of(context).pop({
                                        'id': category.id,
                                        'name': category.name,
                                      });
                                    },
                                  ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type;
  final String? categoryGroup; // 'living', 'incidental', 'fixed', 'investment'

  _CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = 'EXPENSE',
    this.categoryGroup,
  });
}

class _CategoryGroup extends StatelessWidget {
  final String title;
  final List<_CategoryItem> items;
  final IconData icon;
  final Color color;
  final Function(_CategoryItem) onTap;

  const _CategoryGroup({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: items
                .map(
                  (item) => GestureDetector(
                    onTap: () => onTap(item),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SizedBox(
                          width: 72,
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _JarItem {
  final String id;
  final String name;
  final String amount;
  final String percentage;
  final Color color;

  _JarItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class _JarGroup extends StatelessWidget {
  final String title;
  final List<_JarItem> items;
  final IconData icon;
  final Color color;
  final Function(_JarItem) onTap;

  const _JarGroup({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: items
                .map(
                  (item) => GestureDetector(
                    onTap: () => onTap(item),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Icons.savings_outlined,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SizedBox(
                          width: 72,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray800,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.amount} • ${item.percentage}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray500,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet chọn hũ
class _JarPickerSheet extends StatefulWidget {
  const _JarPickerSheet();

  @override
  State<_JarPickerSheet> createState() => _JarPickerSheetState();
}

class _JarPickerSheetState extends State<_JarPickerSheet> {
  List<_JarItem> _jars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJars();
  }

  Future<void> _loadJars() async {
    try {
      final getCurrentUser = GetCurrentUser(DI.authRepository);
      final user = getCurrentUser();
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Lấy jars với ID từ database
      final res = await SupabaseConfig.client
          .from('jars')
          .select('id, name, balance, percentage')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: true);

      final colors = <Color>[
        AppColors.error,
        AppColors.info,
        AppColors.warning,
        AppColors.primary,
        AppColors.success,
        AppColors.secondary,
      ];

      setState(() {
        _jars = (res as List).asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value as Map<String, dynamic>;
          final name = (row['name'] as String?) ?? 'Jar';
          final percentage = (row['percentage'] as int?) ?? 0;
          final balance = (row['balance'] as num?) ?? 0;
          final color = colors[index % colors.length];

          return _JarItem(
            id: row['id'] as String,
            name: name,
            amount: _formatCurrency(balance),
            percentage: '$percentage%',
            color: color,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K ₫';
    }
    return '${amount.toStringAsFixed(0)} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Chọn hũ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _jars.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 48,
                                    color: AppColors.gray400,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Chưa có hũ nào',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.sm),
                                // Hiển thị tất cả hũ trong một nhóm
                                _JarGroup(
                                  title: 'Hũ tài chính',
                                  icon: Icons.account_balance_wallet,
                                  color: AppColors.primary,
                                  items: _jars,
                                  onTap: (jar) {
                                    Navigator.of(context).pop({
                                      'id': jar.id,
                                      'name': jar.name,
                                    });
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

