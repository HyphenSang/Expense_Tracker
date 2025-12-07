import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/category_service.dart';

/// Màn hình tạo danh mục mới (full screen).
class CreateCategoryScreen extends StatefulWidget {
  final bool initialIsExpense;

  const CreateCategoryScreen({
    super.key,
    this.initialIsExpense = true,
  });

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool _isExpense = true;
  bool _isCreating = false;
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = AppColors.gray500;
  int _maxNameLength = 30;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _IconPickerSheet(
        currentIcon: _selectedIcon,
        currentColor: _selectedColor,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result['icon'] as IconData;
        _selectedColor = result['color'] as Color;
      });
    }
  }

  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Convert IconData to string (tên icon)
      final iconName = _iconDataToString(_selectedIcon);
      // Convert Color to hex string
      final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

      await CategoryService.createCategory(
        name: name,
        type: _isExpense ? 'EXPENSE' : 'INCOME',
        icon: iconName,
        color: colorHex,
      );

      if (!mounted) return;

      // Trả về tên danh mục mới
      Navigator.of(context).pop(name);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo danh mục "$name" thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo danh mục: $e'),
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

  String _iconDataToString(IconData icon) {
    // Map IconData to string name (đơn giản hóa)
    return icon.codePoint.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameLength = _nameController.text.length;
    final isValid = nameLength >= 2 && nameLength <= _maxNameLength;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tạo danh mục'),
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
                // Loại danh mục (Chi tiêu/Thu nhập)
                _TypeSelector(
                  isExpense: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl * 2),
                
                // Chọn icon
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickIcon,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _selectedColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _selectedIcon,
                            size: 56,
                            color: _selectedColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _pickIcon,
                        child: Text(
                          'Đổi biểu tượng',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl * 2),
                
                // Tên danh mục
                Text(
                  'Tên danh mục ($nameLength/$_maxNameLength)*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên',
                    suffixText: '$nameLength/$_maxNameLength',
                    suffixStyle: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: _maxNameLength,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên danh mục';
                    }
                    if (value.trim().length < 2) {
                      return 'Tên danh mục phải có ít nhất 2 ký tự';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Thuộc danh mục (Parent category) - tùy chọn
                Text(
                  'Thuộc danh mục (tùy chọn)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: InputDecoration(
                    hintText: 'Chọn',
                    filled: true,
                    fillColor: AppColors.gray100.withValues(alpha: 0.5), // Khung mờ
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.gray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    suffixIcon: const Icon(Icons.chevron_right),
                  ),
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: 'living',
                      child: Text('Chi tiêu - sinh hoạt'),
                    ),
                    DropdownMenuItem(
                      value: 'incidental',
                      child: Text('Chi phí phát sinh'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed',
                      child: Text('Chi phí cố định'),
                    ),
                    DropdownMenuItem(
                      value: 'investment',
                      child: Text('Đầu tư - tiết kiệm'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Lưu parent category khi có database field
                  },
                ),
                const SizedBox(height: AppSpacing.xl * 2),
                
                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid && !_isCreating ? _createCategory : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      backgroundColor: isValid ? AppColors.primary : AppColors.gray300,
                      foregroundColor: isValid ? AppColors.gray900 : AppColors.gray500,
                      disabledBackgroundColor: AppColors.gray300,
                      disabledForegroundColor: AppColors.gray500,
                    ),
                    child: Text(
                      _isCreating ? 'Đang tạo...' : 'Xác nhận',
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

/// Selector cho loại danh mục (Chi tiêu/Thu nhập).
class _TypeSelector extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const _TypeSelector({
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: isExpense ? AppColors.gray900 : AppColors.gray400,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Chi tiêu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isExpense ? AppColors.gray900 : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: !isExpense ? AppColors.gray900 : AppColors.gray400,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Thu nhập',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: !isExpense ? AppColors.gray900 : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet để chọn icon.
class _IconPickerSheet extends StatefulWidget {
  final IconData currentIcon;
  final Color currentColor;

  const _IconPickerSheet({
    required this.currentIcon,
    required this.currentColor,
  });

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  IconData? _selectedIcon;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.currentIcon;
    _selectedColor = widget.currentColor;
  }

  final List<Map<String, dynamic>> _availableIcons = [
    // Row 1
    {'icon': Icons.favorite, 'color': const Color(0xFFEF4444), 'name': 'Yêu thích'},
    {'icon': Icons.receipt_long, 'color': const Color(0xFFEF4444), 'name': 'Hóa đơn'},
    {'icon': Icons.toys, 'color': const Color(0xFFFFB74D), 'name': 'Đồ chơi'},
    {'icon': Icons.headphones, 'color': const Color(0xFF3B82F6), 'name': 'Tai nghe'},
    {'icon': Icons.laptop, 'color': const Color(0xFF3B82F6), 'name': 'Laptop'},
    {'icon': Icons.chair, 'color': const Color(0xFF8B5CF6), 'name': 'Ghế'},
    
    // Row 2
    {'icon': Icons.shield, 'color': const Color(0xFFFFEB3B), 'name': 'Bảo vệ'},
    {'icon': Icons.bolt, 'color': const Color(0xFF42A5F5), 'name': 'Điện'},
    {'icon': Icons.favorite_border, 'color': const Color(0xFF10B981), 'name': 'Yêu thích'},
    {'icon': Icons.add_circle, 'color': const Color(0xFFE91E63), 'name': 'Thêm'},
    {'icon': Icons.card_giftcard, 'color': const Color(0xFFFFB74D), 'name': 'Quà tặng'},
    {'icon': Icons.spa, 'color': const Color(0xFFE91E63), 'name': 'Spa'},
    
    // Row 3
    {'icon': Icons.menu_book, 'color': const Color(0xFFFFEB3B), 'name': 'Sách'},
    {'icon': Icons.redeem, 'color': const Color(0xFF8B5CF6), 'name': 'Quà'},
    {'icon': Icons.flight, 'color': const Color(0xFF42A5F5), 'name': 'Máy bay'},
    {'icon': Icons.bar_chart, 'color': const Color(0xFFEF4444), 'name': 'Biểu đồ'},
    {'icon': Icons.account_balance_wallet, 'color': const Color(0xFF10B981), 'name': 'Ví'},
    {'icon': Icons.water_drop, 'color': const Color(0xFF42A5F5), 'name': 'Nước'},
    
    // Row 4
    {'icon': Icons.settings, 'color': const Color(0xFF10B981), 'name': 'Cài đặt'},
    {'icon': Icons.account_balance, 'color': const Color(0xFFEF4444), 'name': 'Ngân hàng'},
    {'icon': Icons.phone_android, 'color': const Color(0xFF3B82F6), 'name': 'Điện thoại'},
    {'icon': Icons.business, 'color': const Color(0xFF10B981), 'name': 'Doanh nghiệp'},
    {'icon': Icons.restaurant_menu, 'color': const Color(0xFFFFB74D), 'name': 'Nhà hàng'},
    {'icon': Icons.local_parking, 'color': const Color(0xFF42A5F5), 'name': 'Đỗ xe'},
    
    // Row 5
    {'icon': Icons.build, 'color': const Color(0xFF10B981), 'name': 'Sửa chữa'},
    {'icon': Icons.sports_basketball, 'color': const Color(0xFFFFB74D), 'name': 'Bóng rổ'},
    {'icon': Icons.checkroom, 'color': const Color(0xFF8B5CF6), 'name': 'Quần áo'},
    {'icon': Icons.soup_kitchen, 'color': const Color(0xFFFFB74D), 'name': 'Nấu ăn'},
    {'icon': Icons.school, 'color': const Color(0xFF8B5CF6), 'name': 'Giáo dục'},
    {'icon': Icons.handshake, 'color': const Color(0xFF8B5CF6), 'name': 'Hợp tác'},
    
    // Row 6
    {'icon': Icons.battery_charging_full, 'color': const Color(0xFFFFB74D), 'name': 'Pin'},
    {'icon': Icons.favorite, 'color': const Color(0xFFE91E63), 'name': 'Yêu thích'},
    {'icon': Icons.people, 'color': const Color(0xFFFFEB3B), 'name': 'Nhóm'},
    {'icon': Icons.restaurant, 'color': const Color(0xFFFFB74D), 'name': 'Ăn uống'},
    {'icon': Icons.pets, 'color': const Color(0xFFEF4444), 'name': 'Thú cưng'},
    {'icon': Icons.local_bar, 'color': const Color(0xFFFFB74D), 'name': 'Bar'},
    
    // Row 7
    {'icon': Icons.local_gas_station, 'color': const Color(0xFF42A5F5), 'name': 'Xăng'},
    {'icon': Icons.medication, 'color': const Color(0xFFFFB74D), 'name': 'Thuốc'},
    {'icon': Icons.person, 'color': const Color(0xFF8B5CF6), 'name': 'Người'},
    {'icon': Icons.monetization_on, 'color': const Color(0xFFEF4444), 'name': 'Tiền'},
    {'icon': Icons.location_city, 'color': const Color(0xFFFFB74D), 'name': 'Thành phố'},
    {'icon': Icons.dining, 'color': const Color(0xFFFFB74D), 'name': 'Bữa ăn'},
    
    // Row 8
    {'icon': Icons.pets, 'color': const Color(0xFFE91E63), 'name': 'Thú cưng'},
    {'icon': Icons.local_hospital, 'color': const Color(0xFFEF4444), 'name': 'Bệnh viện'},
    
    // Thêm các icon phổ biến khác
    {'icon': Icons.shopping_cart, 'color': const Color(0xFFFFB300), 'name': 'Giỏ hàng'},
    {'icon': Icons.directions_car, 'color': const Color(0xFF42A5F5), 'name': 'Xe hơi'},
    {'icon': Icons.home, 'color': const Color(0xFF42A5F5), 'name': 'Nhà'},
    {'icon': Icons.movie, 'color': const Color(0xFFEF4444), 'name': 'Phim'},
    {'icon': Icons.work, 'color': const Color(0xFF3B82F6), 'name': 'Công việc'},
    {'icon': Icons.savings, 'color': const Color(0xFF10B981), 'name': 'Tiết kiệm'},
    {'icon': Icons.trending_up, 'color': const Color(0xFF10B981), 'name': 'Tăng'},
    {'icon': Icons.trending_down, 'color': const Color(0xFFEF4444), 'name': 'Giảm'},
    {'icon': Icons.local_cafe, 'color': const Color(0xFFFFB74D), 'name': 'Cà phê'},
    {'icon': Icons.shopping_bag, 'color': const Color(0xFFFFB74D), 'name': 'Túi mua sắm'},
    {'icon': Icons.receipt, 'color': const Color(0xFF10B981), 'name': 'Biên lai'},
    {'icon': Icons.phone, 'color': const Color(0xFF3B82F6), 'name': 'Điện thoại'},
    {'icon': Icons.wifi, 'color': const Color(0xFF3B82F6), 'name': 'WiFi'},
    {'icon': Icons.power, 'color': const Color(0xFFFFB74D), 'name': 'Năng lượng'},
    {'icon': Icons.category, 'color': AppColors.gray500, 'name': 'Danh mục'},
    {'icon': Icons.brush, 'color': const Color(0xFFE91E63), 'name': 'Làm đẹp'},
    {'icon': Icons.volunteer_activism, 'color': const Color(0xFFFF8A65), 'name': 'Từ thiện'},
    {'icon': Icons.fitness_center, 'color': const Color(0xFFEF4444), 'name': 'Thể thao'},
    {'icon': Icons.credit_card, 'color': const Color(0xFFEF4444), 'name': 'Thẻ tín dụng'},
    {'icon': Icons.account_balance, 'color': const Color(0xFF3B82F6), 'name': 'Ngân hàng'},
    {'icon': Icons.attach_money, 'color': const Color(0xFF10B981), 'name': 'Tiền'},
    {'icon': Icons.payments, 'color': const Color(0xFF10B981), 'name': 'Thanh toán'},
    {'icon': Icons.money_off, 'color': const Color(0xFFEF4444), 'name': 'Không tiền'},
    {'icon': Icons.local_atm, 'color': const Color(0xFFFFB74D), 'name': 'ATM'},
    {'icon': Icons.account_circle, 'color': const Color(0xFF8B5CF6), 'name': 'Tài khoản'},
    {'icon': Icons.refresh, 'color': const Color(0xFF42A5F5), 'name': 'Làm mới'},
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFFB74D), // Cam
    const Color(0xFFFFB300), // Vàng cam
    const Color(0xFF42A5F5), // Xanh dương
    const Color(0xFF10B981), // Xanh lá
    const Color(0xFFEF4444), // Đỏ
    const Color(0xFFE91E63), // Hồng
    const Color(0xFF8B5CF6), // Tím
    const Color(0xFF3B82F6), // Xanh dương đậm
    const Color(0xFFF59E0B), // Cam đậm
    AppColors.gray500, // Xám
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Text(
                    'Chọn biểu tượng',
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
            
            // Grid icons
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu tượng',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = 4;
                        final spacing = AppSpacing.md;
                        final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                        final itemSize = itemWidth.clamp(60.0, 80.0);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: 1,
                          ),
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, index) {
                            final item = _availableIcons[index];
                            final icon = item['icon'] as IconData;
                            final color = item['color'] as Color;
                            final isSelected = _selectedIcon == icon && _selectedColor == color;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIcon = icon;
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withValues(alpha: 0.2)
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: isSelected ? color : AppColors.gray300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: itemSize * 0.5,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Màu sắc
                    Text(
                      'Màu sắc',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor == color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.gray900 : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            
            // Nút xác nhận
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'icon': _selectedIcon ?? widget.currentIcon,
                      'color': _selectedColor ?? widget.currentColor,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.gray900,
                  ),
                  child: Text(
                    'Xác nhận',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

