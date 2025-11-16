import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/select_category.dart';
import 'package:expenses/presentation/screens/create_category.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isExpense = true; // true = Chi tiêu, false = Thu nhập
  String? _selectedCategory;
  String? _selectedCategoryIcon;
  Color? _selectedCategoryColor;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Hôm nay, ${date.day}/${date.month}/${date.year}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCategory() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectCategoryScreen(
        transactionType: _isExpense ? 'EXPENSE' : 'INCOME',
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['name'];
        _selectedCategoryIcon = result['icon'];
        _selectedCategoryColor = result['color'];
      });
    }
  }

  Future<void> _createCategory() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCategoryScreen(
          transactionType: _isExpense ? 'EXPENSE' : 'INCOME',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['name'];
        _selectedCategoryIcon = result['icon'];
        _selectedCategoryColor = result['color'];
      });
    }
  }

  bool get _canSubmit {
    return _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), '')) != null &&
        _selectedCategory != null;
  }

  void _submit() {
    if (!_canSubmit) return;
    // TODO: Save transaction
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm giao dịch thành công!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
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
                            _selectedCategory = null;
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
                            _selectedCategory = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // Amount Input
              Text(
                'Số tiền*',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0 ₫',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Category Input
              Text(
                'Danh mục*',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _selectCategory,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Row(
                    children: [
                      if (_selectedCategoryIcon != null && _selectedCategoryColor != null)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: _selectedCategoryColor!.withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusSM,
                          ),
                          child: Icon(
                            _getIconData(_selectedCategoryIcon!),
                            color: _selectedCategoryColor,
                            size: 20,
                          ),
                        )
                      else
                        Icon(Icons.category, color: AppColors.gray400),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _selectedCategory ?? 'Chọn danh mục',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _selectedCategory != null
                                    ? AppColors.gray900
                                    : AppColors.gray400,
                              ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.gray400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Create Category Button
              TextButton.icon(
                onPressed: _createCategory,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Tạo danh mục mới'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Date Input
              Text(
                'Ngày giao dịch*',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.gray400),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _formatDate(_selectedDate),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.gray900,
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
                  'Thêm giao dịch',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _canSubmit ? AppColors.gray900 : AppColors.gray500,
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Thêm vào lúc khác',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
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

