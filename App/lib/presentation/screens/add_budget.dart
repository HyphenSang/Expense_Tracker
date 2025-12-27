import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/category.dart';
import 'package:expenses/core/supabase_flutter.dart';

/// Màn hình tạo/chỉnh sửa ngân sách.
class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  String _budgetType = 'category'; // 'category' hoặc 'jar'
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedJarId;
  String? _selectedJarName;
  String _selectedPeriod = 'MONTHLY'; // MONTHLY, WEEKLY, YEARLY
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isCreating = false;

  // Use cases
  final _getCurrentUser = GetCurrentUser(DI.authRepository);

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

  Future<void> _pickJar() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => const _JarPickerSheet(),
    );

    if (result != null) {
      setState(() {
        _selectedJarId = result['id'];
        _selectedJarName = result['name'];
      });
    }
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

    if (_budgetType == 'category' && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_budgetType == 'jar' && _selectedJarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hũ'),
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

      // TODO: Gọi API tạo budget
      // final user = _getCurrentUser();
      // if (user == null) {
      //   throw StateError('Chưa đăng nhập');
      // }
      // await createBudget(...);

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo ngân sách thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo ngân sách: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _limitController.text.isNotEmpty &&
        ((_budgetType == 'category' && _selectedCategoryId != null) ||
            (_budgetType == 'jar' && _selectedJarId != null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo ngân sách'),
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
                // Loại ngân sách (Danh mục/Hũ)
                Text(
                  'Loại ngân sách*',
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
                              _budgetType = 'category';
                              _selectedJarId = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _budgetType == 'category'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Theo danh mục',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _budgetType == 'category'
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
                              _budgetType = 'jar';
                              _selectedCategoryId = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _budgetType == 'jar'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Theo hũ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _budgetType == 'jar'
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

                // Chọn danh mục hoặc hũ
                if (_budgetType == 'category') ...[
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
                ] else ...[
                  Text(
                    'Hũ*',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: _pickJar,
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
                          const Icon(Icons.account_balance_wallet_outlined,
                              color: AppColors.gray700),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                              _selectedJarName ?? 'Chọn hũ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _selectedJarName == null
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
                ],
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
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: Align(
                        widthFactor: 1.0,
                        child: Text(
                          '\$',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 0,
                    ),
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
                      _isCreating ? 'Đang tạo...' : 'Tạo ngân sách',
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
    // Map icon name string to IconData - giống như trong add_transaction
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    
    // Map các icon phổ biến
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
          final name = cat.name.toLowerCase();
          return name.contains('hóa đơn') ||
              name.contains('nhà cửa') ||
              name.contains('người thân');
        }).toList();
      case 'Đầu tư - tiết kiệm':
        return all.where((cat) {
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

  _CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = 'EXPENSE',
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

