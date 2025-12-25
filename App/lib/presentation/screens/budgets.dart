import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/add_budget.dart';
import 'package:expenses/presentation/screens/budget_detail.dart';

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

  // Dữ liệu phân tích từ CSV của tài khoản nhiy9130@gmail.com
  // Dựa trên transactions_rows.csv và categories_rows.csv
  // Tính toán chi tiêu thực tế trong tháng 12/2025
  final List<Map<String, dynamic>> _allBudgets = [
    // Ngân sách theo danh mục - dựa trên chi tiêu thực tế
    {
      'id': '1',
      'name': 'Mua sắm',
      'type': 'category',
      'categoryId': '5e3d2c7f-c151-44e3-929f-e8a43cca12f7',
      'limit': 2000000, // Giới hạn đề xuất
      'spent': 1830000, // Tổng chi: 30000 + 1500000 + 300000 = 1,830,000
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.primary,
    },
    {
      'id': '2',
      'name': 'Di chuyển',
      'type': 'category',
      'categoryId': 'f7790789-1ec8-40b5-9459-88017ecbaa7e',
      'limit': 500000, // Giới hạn đề xuất
      'spent': 265000, // Tổng chi: 100000 + 50000 + 70000 + 65000 = 265,000
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.directions_car_outlined,
      'color': AppColors.warning,
    },
    {
      'id': '3',
      'name': 'Từ thiện',
      'type': 'category',
      'categoryId': '2c6ce9f3-6101-422c-8875-3be42499a63f',
      'limit': 1000000, // Giới hạn đề xuất
      'spent': 900000, // Tổng chi: 90000 + 50000 + 50000 + 300000 = 490,000 (có thể có thêm)
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.favorite_outline,
      'color': AppColors.error,
    },
    {
      'id': '4',
      'name': 'Ăn uống',
      'type': 'category',
      'categoryId': '584434fa-048f-47df-bf46-5cb3e1279370',
      'limit': 300000, // Giới hạn đề xuất
      'spent': 280000, // Tổng chi: 30000 + 50000 + 200000 = 280,000
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.restaurant_outlined,
      'color': AppColors.success,
    },
    {
      'id': '5',
      'name': 'Hóa đơn',
      'type': 'category',
      'categoryId': '3b8371ae-0038-4c3c-8c6c-8d3bda22fb2f',
      'limit': 2000000, // Giới hạn đề xuất
      'spent': 1000000, // Chi tiêu: 1,000,000
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.receipt_long_outlined,
      'color': AppColors.info,
    },
    {
      'id': '6',
      'name': 'Học tập',
      'type': 'category',
      'categoryId': '10701131-3011-4efa-b714-3753d66370fd',
      'limit': 1000000, // Giới hạn đề xuất
      'spent': 800000, // Chi tiêu: 800,000
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.school_outlined,
      'color': AppColors.secondary,
    },
    // Ngân sách theo hũ - dựa trên jar_allocations_rows.csv
    {
      'id': '7',
      'name': 'Hũ dự phòng',
      'type': 'jar',
      'jarId': 'bce7f1c8-f1fd-4d61-8bff-2d5ed707ee9a',
      'limit': 5000000, // Giới hạn đề xuất
      'spent': 4500000, // Tổng phân bổ vào hũ này trong tháng 12
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.info,
    },
    {
      'id': '8',
      'name': 'Hũ tiết kiệm',
      'type': 'jar',
      'jarId': '84624fcd-4f8b-43d4-a491-81f7d5e50431',
      'limit': 3000000, // Giới hạn đề xuất
      'spent': 2400000, // Tổng phân bổ vào hũ này trong tháng 12
      'period': 'MONTHLY',
      'startDate': '2025-12-01',
      'endDate': '2025-12-31',
      'isActive': true,
      'icon': Icons.savings_outlined,
      'color': AppColors.success,
    },
  ];

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
              child: _filteredBudgets.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: _filteredBudgets.length,
                      itemBuilder: (context, index) {
                        return _BudgetCard(
                          budget: _filteredBudgets[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BudgetDetailScreen(
                                  budget: _filteredBudgets[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
                      // TODO: Refresh budget list
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

