import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';

/// Màn hình lịch sử giao dịch với 2 tab: Hoạt động và Thống kê.
class TransactionsHistoryScreen extends StatefulWidget {
  final int initialTab; // 0: Hoạt động, 1: Thống kê

  const TransactionsHistoryScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  // Thống kê
  DateTime _selectedMonth = DateTime.now();
  Map<String, num>? _incomeExpense;
  Map<String, dynamic>? _comparison;
  List<CategorySpendingSummary>? _categorySpending;
  List<CategorySpendingSummary>? _categoryIncome; // Thêm dữ liệu thu nhập
  bool _isSubCategory = true; // true: Danh mục con, false: Danh mục cha
  final Set<String> _expandedParents = {}; // Track expanded parent categories
  bool _isExpenseSelected = true; // true: Chi tiêu được chọn, false: Thu nhập được chọn

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final incomeExpense = await ExpenseService.getIncomeExpenseForMonth(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      final comparison = await ExpenseService.getMonthComparison(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      final categories = await ExpenseService.getCategorySpendingForMonth(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      final incomeCategories = await ExpenseService.getCategoryIncomeForMonth(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );

      if (mounted) {
        setState(() {
          _incomeExpense = incomeExpense;
          _comparison = comparison;
          _categorySpending = categories;
          _categoryIncome = incomeCategories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải thống kê: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị tab Thống kê, bỏ tab Hoạt động
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 0, // Bỏ khoảng trắng giữa AppBar và body
        elevation: 0,
      ),
      body: _buildStatisticsTab(),
    );
  }


  Widget _buildStatisticsTab() {
    final income = _incomeExpense?['income'] ?? 0;
    final expense = _incomeExpense?['expense'] ?? 0;
    final change = _comparison?['change'] as Map<String, num>?;
    final expenseChange = change?['expense'] ?? 0;
    final incomeChange = change?['income'] ?? 0;
    
    // Chọn change dựa trên card được chọn
    final selectedChange = _isExpenseSelected ? expenseChange : incomeChange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tình hình thu chi
          Text(
            'Tình hình thu chi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tháng ${_selectedMonth.month}/${_selectedMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Income/Expense cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Chi tiêu',
                  amount: ExpenseService.formatCurrency(expense),
                  icon: Icons.trending_up,
                  color: AppColors.error,
                  isSelected: _isExpenseSelected,
                  onTap: () {
                    setState(() {
                      _isExpenseSelected = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: 'Thu nhập',
                  amount: ExpenseService.formatCurrency(income),
                  icon: Icons.trending_down,
                  color: AppColors.success,
                  isSelected: !_isExpenseSelected,
                  onTap: () {
                    setState(() {
                      _isExpenseSelected = false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Comparison bar - hiển thị so sánh theo card được chọn
          if (selectedChange != 0)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      selectedChange > 0
                          ? 'Tăng ${ExpenseService.formatCurrency(selectedChange.abs())} so với cùng kỳ tháng trước'
                          : 'Giảm ${ExpenseService.formatCurrency(selectedChange.abs())} so với cùng kỳ tháng trước',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl * 2),

          // Donut chart - hiển thị theo card được chọn
          if (_isExpenseSelected) ...[
            // Biểu đồ chi tiêu
            if (_categorySpending != null && _categorySpending!.isNotEmpty) ...[
              _DonutChart(categories: _categorySpending!),
              const SizedBox(height: AppSpacing.xl * 2),
              // Category tabs
              Row(
                children: [
                  Expanded(
                    child: _CategoryTab(
                      label: 'Danh mục con',
                      isSelected: _isSubCategory,
                      onTap: () => setState(() => _isSubCategory = true),
                    ),
                  ),
                  Expanded(
                    child: _CategoryTab(
                      label: 'Danh mục cha',
                      isSelected: !_isSubCategory,
                      onTap: () => setState(() => _isSubCategory = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Category list
              ...(_isSubCategory
                  ? // Hiển thị danh mục con (chi tiết)
                    _categorySpending!.map((cat) => _CategoryListItem(
                          name: cat.name,
                          amount: ExpenseService.formatCurrency(cat.amount),
                          percentage: '${cat.percentage.toStringAsFixed(1)}%',
                          icon: cat.icon,
                          color: cat.color,
                          isSubCategory: true,
                        )).toList()
                  : // Hiển thị danh mục cha (nhóm)
                    _buildParentCategories(_categorySpending!)),
            ],
          ] else ...[
            // Biểu đồ thu nhập
            if (_categoryIncome != null && _categoryIncome!.isNotEmpty) ...[
              _DonutChart(categories: _categoryIncome!),
              const SizedBox(height: AppSpacing.xl * 2),
              // Category tabs
              Row(
                children: [
                  Expanded(
                    child: _CategoryTab(
                      label: 'Danh mục con',
                      isSelected: _isSubCategory,
                      onTap: () => setState(() => _isSubCategory = true),
                    ),
                  ),
                  Expanded(
                    child: _CategoryTab(
                      label: 'Danh mục cha',
                      isSelected: !_isSubCategory,
                      onTap: () => setState(() => _isSubCategory = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Category list
              ...(_isSubCategory
                  ? // Hiển thị danh mục con (chi tiết)
                    _categoryIncome!.map((cat) => _CategoryListItem(
                          name: cat.name,
                          amount: ExpenseService.formatCurrency(cat.amount),
                          percentage: '${cat.percentage.toStringAsFixed(1)}%',
                          icon: cat.icon,
                          color: cat.color,
                          isSubCategory: true,
                        )).toList()
                  : // Hiển thị danh mục cha (nhóm)
                    _buildParentCategories(_categoryIncome!)),
            ],
          ],
        ],
      ),
    );
  }

  /// Nhóm categories thành parent categories.
  List<Widget> _buildParentCategories(List<CategorySpendingSummary> categories) {
    // Mapping categories vào parent groups
    final Map<String, List<CategorySpendingSummary>> parentGroups = {};
    
    for (final cat in categories) {
      String parentName;
      
      // Phân loại vào nhóm cha dựa trên tên
      final nameLower = cat.name.toLowerCase();
      if (nameLower.contains('chợ') || 
          nameLower.contains('siêu thị') ||
          nameLower.contains('ăn uống') ||
          nameLower.contains('di chuyển')) {
        parentName = 'Chi tiêu - sinh hoạt';
      } else if (nameLower.contains('mua sắm') ||
                 nameLower.contains('giải trí') ||
                 nameLower.contains('làm đẹp') ||
                 nameLower.contains('sức khỏe') ||
                 nameLower.contains('từ thiện')) {
        parentName = 'Chi phí phát sinh';
      } else if (nameLower.contains('hóa đơn') ||
                 nameLower.contains('nhà cửa') ||
                 nameLower.contains('người thân')) {
        parentName = 'Chi phí cố định';
      } else {
        parentName = 'Chưa phân loại';
      }
      
      if (!parentGroups.containsKey(parentName)) {
        parentGroups[parentName] = [];
      }
      parentGroups[parentName]!.add(cat);
    }
    
    // Tính tổng cho mỗi nhóm cha
    return parentGroups.entries.map((entry) {
      final totalAmount = entry.value.fold<num>(
        0,
        (sum, cat) => sum + cat.amount,
      );
      final totalPercentage = entry.value.fold<double>(
        0.0,
        (sum, cat) => sum + cat.percentage,
      );
      
      // Tìm icon và color từ category đầu tiên
      final firstCat = entry.value.first;
      final isExpanded = _expandedParents.contains(entry.key);
      
      return _ParentCategoryItem(
        name: entry.key,
        amount: ExpenseService.formatCurrency(totalAmount),
        percentage: '${totalPercentage.toStringAsFixed(1)}%',
        icon: firstCat.icon,
        color: firstCat.color,
        isExpanded: isExpanded,
        subCategories: entry.value,
        onToggle: () {
          setState(() {
            if (isExpanded) {
              _expandedParents.remove(entry.key);
            } else {
              _expandedParents.add(entry.key);
            }
          });
        },
      );
    }).toList();
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? color : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<CategorySpendingSummary> categories;

  const _DonutChart({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final pieData = categories.asMap().entries.map((entry) {
      final cat = entry.value;
      // Sử dụng màu từ category thay vì màu mặc định
      return PieChartSectionData(
        value: cat.percentage,
        color: cat.color,
        title: '${cat.percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: pieData,
                sectionsSpace: 2,
                centerSpaceRadius: 60,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Legend list giống dashboard
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: categories.map((cat) {
              // Sử dụng màu từ category
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${cat.percentage.toStringAsFixed(0)}% ${cat.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray700,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final String name;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final bool isSubCategory;

  const _CategoryListItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    this.isSubCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // Bỏ background trắng và border
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Icon giống như trong create category screen
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                Text(
                  percentage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          // Bỏ mũi tên sang phải cho danh mục con
          if (!isSubCategory) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ],
      ),
    );
  }
}

class _ParentCategoryItem extends StatelessWidget {
  final String name;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final bool isExpanded;
  final List<CategorySpendingSummary> subCategories;
  final VoidCallback onToggle;

  const _ParentCategoryItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.isExpanded,
    required this.subCategories,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                // Giữ khung như cũ nhưng màu nhạt hơn
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: color.withValues(alpha: 0.2), // Màu nhạt hơn
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon với màu nhạt hơn
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.2), // Màu nhạt hơn
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, color: color.withValues(alpha: 0.7), size: 24), // Màu nhạt hơn
                  ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      Text(
                        percentage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 24,
                  color: AppColors.gray700,
                ),
              ],
            ),
          ),
        ),
        // Hiển thị danh mục con khi expanded
        if (isExpanded)
          ...subCategories.map((subCat) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl * 2, bottom: AppSpacing.sm),
                child: _CategoryListItem(
                  name: subCat.name,
                  amount: ExpenseService.formatCurrency(subCat.amount),
                  percentage: '${subCat.percentage.toStringAsFixed(1)}%',
                  icon: subCat.icon,
                  color: subCat.color,
                  isSubCategory: true, // Bỏ mũi tên
                ),
              )),
      ],
    );
  }
}

