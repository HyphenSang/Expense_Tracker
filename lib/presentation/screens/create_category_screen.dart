import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/icon_picker_screen.dart';

class CreateCategoryScreen extends StatefulWidget {
  final String transactionType; // 'EXPENSE' or 'INCOME'

  const CreateCategoryScreen({
    super.key,
    required this.transactionType,
  });

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _parentCategoryController = TextEditingController();
  bool _isExpense = true;
  String? _selectedIcon;
  Color _selectedColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.transactionType == 'EXPENSE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectIcon() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IconPickerScreen(),
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result['icon'];
        _selectedColor = result['color'] ?? AppColors.primary;
      });
    }
  }

  bool get _canSubmit {
    return _nameController.text.isNotEmpty && _selectedIcon != null;
  }

  void _submit() {
    if (!_canSubmit) return;
    Navigator.pop(context, {
      'name': _nameController.text,
      'icon': _selectedIcon,
      'color': _selectedColor,
    });
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.category;
    final iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'school': Icons.school,
      'favorite': Icons.favorite,
      'movie': Icons.movie,
      'account_balance_wallet': Icons.account_balance_wallet,
      'work': Icons.work,
      'savings': Icons.savings,
      'trending_up': Icons.trending_up,
      'trending_down': Icons.trending_down,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tạo danh mục'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Type Tabs
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TransactionTypeTab(
                        label: 'Chi tiêu',
                        icon: Icons.trending_up,
                        isSelected: _isExpense,
                        onTap: () {
                          setState(() {
                            _isExpense = true;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _TransactionTypeTab(
                        label: 'Thu nhập',
                        icon: Icons.trending_down,
                        isSelected: !_isExpense,
                        onTap: () {
                          setState(() {
                            _isExpense = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // Icon Selection
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _selectIcon,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _selectedColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(_selectedIcon),
                          size: 50,
                          color: _selectedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _selectIcon,
                      child: Text(
                        'Đổi biểu tượng',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // Category Name Input
              Text(
                'Tên danh mục (${_nameController.text.length}/30)*',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                maxLength: 30,
                decoration: InputDecoration(
                  hintText: 'Nhập tên',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Parent Category (Optional)
              Text(
                'Thuộc danh mục',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () {
                  // TODO: Show parent category picker
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _parentCategoryController.text.isEmpty
                              ? 'Chọn'
                              : _parentCategoryController.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _parentCategoryController.text.isEmpty
                                    ? AppColors.gray400
                                    : AppColors.gray900,
                              ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.gray400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // Submit Button
              ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.gray900,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLG,
                  ),
                  disabledBackgroundColor: AppColors.gray300,
                ),
                child: Text(
                  'Xác nhận',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _canSubmit ? AppColors.gray900 : AppColors.gray500,
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

class _TransactionTypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionTypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMD,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gray900 : AppColors.gray500,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.gray900 : AppColors.gray500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

