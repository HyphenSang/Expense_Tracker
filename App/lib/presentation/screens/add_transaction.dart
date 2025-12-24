import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/transaction.dart';
import 'package:expenses/service/category.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/presentation/screens/create_category.dart';
import 'package:expenses/service/notification_realtime.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isExpense = true;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _CategoryPickerSheet(
        isExpense: _isExpense,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final amountText = _amountController.text.replaceAll('.', '');
    final amount = int.tryParse(amountText) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await TransactionService.createTransaction(
        isExpense: _isExpense,
        amount: amount,
        categoryName: _selectedCategory!,
        occurredAt: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (!mounted) return;
      
      // Reload notifications ngay sau khi tạo transaction thành công
      await NotificationRealtimeService.reloadNotifications();
      
      // Trả về true để báo hiệu đã thêm thành công
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm giao dịch ${_isExpense ? 'chi tiêu' : 'thu nhập'} thành công',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể thêm giao dịch: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _amountController.text.isNotEmpty && _selectedCategory != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeToggle(
                  isExpense: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Số tiền*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandSeparatorFormatter(),
                  ],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'đ',
                    hintText: '0 đ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    final raw = value.replaceAll('.', '');
                    final amount = int.tryParse(raw) ?? 0;
                    if (amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.xl),
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
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined, color: AppColors.gray700),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            _selectedCategory ?? 'Chọn danh mục',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _selectedCategory == null
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
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickCategory,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tạo danh mục mới'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Ngày giao dịch*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.gray700),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            'Hôm nay, ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                  ),
                  maxLines: 2,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !_isSubmitting && isValid ? _submit : null,
                    child: Text(_isSubmitting ? 'Đang lưu...' : 'Thêm giao dịch'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Thêm vào lúc khác'),
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

class _TypeToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const _TypeToggle({
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Chi tiêu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpense ? AppColors.gray900 : AppColors.gray600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Thu nhập',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: !isExpense ? AppColors.gray900 : AppColors.gray600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  final bool isExpense;

  const _CategoryPickerSheet({
    required this.isExpense,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<_CategoryItem> _userCategories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCategories() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingCategories = false;
        });
        return;
      }

      // Load tất cả danh mục của user (cả EXPENSE và INCOME)
      final categories = await CategoryService.getCategories();

      setState(() {
        _userCategories = categories.map((cat) {
          // Parse màu từ hex string
          Color? color;
          try {
            final colorStr = (cat['color'] as String?) ?? '#6B7280';
            color = Color(int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000);
          } catch (_) {
            color = AppColors.gray500;
          }

          return _CategoryItem(
            name: cat['name'] as String,
            icon: _getIconFromString(cat['icon'] as String?),
            color: color,
            type: cat['type'] as String? ?? 'EXPENSE', // Lưu type để phân loại
          );
        }).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  IconData _getIconFromString(String? iconName) {
    // Map icon name string to IconData
    // Có thể mở rộng sau
    return Icons.category;
  }

  List<_CategoryItem> _filterCategories(List<_CategoryItem> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    final query = _searchQuery.toLowerCase();
    return categories.where((category) {
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  List<_CategoryItem> _getExpenseCategories() {
    // Kết hợp danh mục chi tiêu mặc định với danh mục chi tiêu của user
    final defaultCategories = _getDefaultExpenseCategories();
    
    // Lọc danh mục chi tiêu của user
    final userExpenseCategories = _userCategories.where((c) => c.type == 'EXPENSE').toList();
    
    // Lọc bỏ danh mục trùng tên
    final defaultNames = defaultCategories.map((c) => c.name.toLowerCase()).toSet();
    final uniqueUserCategories = userExpenseCategories.where((c) => !defaultNames.contains(c.name.toLowerCase())).toList();
    
    return [...defaultCategories, ...uniqueUserCategories];
  }

  List<_CategoryItem> _getIncomeCategories() {
    // Kết hợp danh mục thu nhập mặc định với danh mục thu nhập của user
    final defaultCategories = _getDefaultIncomeCategories();
    
    // Lọc danh mục thu nhập của user
    final userIncomeCategories = _userCategories.where((c) => c.type == 'INCOME').toList();
    
    // Lọc bỏ danh mục trùng tên
    final defaultNames = defaultCategories.map((c) => c.name.toLowerCase()).toSet();
    final uniqueUserCategories = userIncomeCategories.where((c) => !defaultNames.contains(c.name.toLowerCase())).toList();
    
    return [...defaultCategories, ...uniqueUserCategories];
  }

  List<_CategoryItem> _getDefaultExpenseCategories() {
    return [
      // Chi tiêu - sinh hoạt
      _CategoryItem(
        name: 'Chợ, siêu thị',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFFFFB74D), // Orange
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Ăn uống',
        icon: Icons.restaurant_outlined,
        color: const Color(0xFFFFE651), // Vàng hơn, không quá chói
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Di chuyển',
        icon: Icons.directions_car_outlined,
        color: const Color(0xFF42A5F5), // Blue
        type: 'EXPENSE',
      ),
      // Chi phí phát sinh
      _CategoryItem(
        name: 'Mua sắm',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFEC407A), // Pink đậm
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Giải trí',
        icon: Icons.card_giftcard_outlined, // Gift box icon
        color: const Color(0xFFAB47BC), // Purple
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Làm đẹp',
        icon: Icons.brush_outlined,
        color: const Color(0xFFE91E63), // Pink đỏ
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Sức khỏe',
        icon: Icons.favorite_outlined, // Heart filled
        color: const Color(0xFFEF5350), // Red
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Từ thiện',
        icon: Icons.volunteer_activism_outlined, // Two hands holding heart
        color: const Color(0xFFFF7043), // Orange đỏ
        type: 'EXPENSE',
      ),
      // Chi phí cố định
      _CategoryItem(
        name: 'Hóa đơn',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF26A69A), // Teal
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Nhà cửa',
        icon: Icons.home_outlined,
        color: const Color(0xFF7E57C2), // Deep purple
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Người thân',
        icon: Icons.people_outline,
        color: const Color(0xFFF06292), // Pink nhạt
        type: 'EXPENSE',
      ),
      // Đầu tư - tiết kiệm
      _CategoryItem(
        name: 'Đầu tư',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF66BB6A), // Green
        type: 'EXPENSE',
      ),
      _CategoryItem(
        name: 'Học tập',
        icon: Icons.school_outlined,
        color: const Color(0xFF5C6BC0), // Indigo
        type: 'EXPENSE',
      ),
    ];
  }

  List<_CategoryItem> _getDefaultIncomeCategories() {
    return [
      _CategoryItem(
        name: 'Lương',
        icon: Icons.work_outline,
        color: const Color(0xFF66BB6A),
        type: 'INCOME',
      ),
      _CategoryItem(
        name: 'Thưởng',
        icon: Icons.card_giftcard_outlined,
        color: const Color(0xFF29B6F6),
        type: 'INCOME',
      ),
      _CategoryItem(
        name: 'Thu nhập phụ',
        icon: Icons.trending_up_outlined,
        color: const Color(0xFF26A69A),
        type: 'INCOME',
      ),
      _CategoryItem(
        name: 'Khác',
        icon: Icons.more_horiz,
        color: AppColors.gray500,
        type: 'INCOME',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final expenseCategories = _getExpenseCategories();
    final incomeCategories = _getIncomeCategories();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header cố định (không scroll)
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
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Không có danh mục bạn cần?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // Mở màn hình tạo danh mục mới (full screen)
                          final result = await Navigator.of(context).push<String>(
                            MaterialPageRoute(
                              builder: (context) => CreateCategoryScreen(
                                initialIsExpense: widget.isExpense,
                              ),
                            ),
                          );
                          
                          // Nếu tạo thành công, reload danh mục và đóng bottom sheet
                          if (result != null && mounted) {
                            await _loadUserCategories();
                            Navigator.of(context).pop(result);
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tạo mới'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Phần danh sách có thể scroll
            Expanded(
              child: _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : Builder(
                      builder: (context) {
                        final filteredExpense = _filterCategories(expenseCategories);
                        final filteredIncome = _filterCategories(incomeCategories);
                  
                  if (_searchQuery.isNotEmpty && filteredExpense.isEmpty && filteredIncome.isEmpty) {
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
                        if (widget.isExpense) ...[
                          // Nhóm "Chi tiêu - sinh hoạt"
                          _CategoryGroup(
                            title: 'Chi tiêu - sinh hoạt',
                            icon: Icons.receipt_long,
                            color: AppColors.warning,
                            items: filteredExpense.where((cat) {
                              final name = cat.name.toLowerCase();
                              return name.contains('chợ') ||
                                  name.contains('siêu thị') ||
                                  name.contains('ăn uống') ||
                                  name.contains('di chuyển');
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Nhóm "Chi phí phát sinh"
                          _CategoryGroup(
                            title: 'Chi phí phát sinh',
                            icon: Icons.account_balance,
                            color: const Color(0xFFFFD54F), // Vàng nhạt hơn, bớt chói
                            items: filteredExpense.where((cat) {
                              final name = cat.name.toLowerCase();
                              return name.contains('mua sắm') ||
                                  name.contains('giải trí') ||
                                  name.contains('làm đẹp') ||
                                  name.contains('sức khỏe') ||
                                  name.contains('từ thiện');
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Nhóm "Chi phí cố định"
                          _CategoryGroup(
                            title: 'Chi phí cố định',
                            icon: Icons.account_balance,
                            color: AppColors.info,
                            items: filteredExpense.where((cat) {
                              final name = cat.name.toLowerCase();
                              return name.contains('hóa đơn') ||
                                  name.contains('nhà cửa') ||
                                  name.contains('người thân');
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Nhóm "Đầu tư - tiết kiệm"
                          _CategoryGroup(
                            title: 'Đầu tư - tiết kiệm',
                            icon: Icons.account_balance_wallet,
                            color: AppColors.success,
                            items: filteredExpense.where((cat) {
                              final name = cat.name.toLowerCase();
                              return name.contains('đầu tư') ||
                                  name.contains('học tập');
                            }).toList(),
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
                            ),
                        ] else ...[
                          // Thu nhập - hiển thị đơn giản
                          if (filteredIncome.isNotEmpty)
                            _CategoryGroup(
                              title: 'Thu nhập',
                              icon: Icons.trending_down,
                              color: AppColors.success,
                              items: filteredIncome,
                            ),
                        ],
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

class _CategoryGroup extends StatelessWidget {
  final String title;
  final List<_CategoryItem> items;
  final IconData icon;
  final Color color;

  const _CategoryGroup({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
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
                    onTap: () => Navigator.of(context).pop(item.name),
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

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'EXPENSE' hoặc 'INCOME'

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    this.type = 'EXPENSE', // Mặc định là EXPENSE
  });
}

/// Format số nguyên sang chuỗi có dấu chấm ngăn cách hàng nghìn.
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reversedIndex = text.length - i - 1;
      buffer.write(text[i]);
      final isThousand = reversedIndex % 3 == 0 && i != text.length - 1;
      if (isThousand) buffer.write('.');
    }
    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


