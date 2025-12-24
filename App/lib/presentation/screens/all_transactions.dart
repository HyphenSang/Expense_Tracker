import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/usecases/auth.dart';
import 'package:expenses/domain/usecases/category.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/domain/usecases/expense.dart';

/// Màn hình xem tất cả giao dịch, sắp xếp theo ngày (gần nhất ở trên).
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  DateTime _selectedMonth = DateTime.now();
  late Future<List<TransactionItemData>?> _transactionsFuture;
  
  // Filter states
  String? _selectedType; // null = tất cả, 'INCOME', 'EXPENSE'
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortOrder = 'newest'; // 'newest', 'oldest', 'amount_high', 'amount_low'
  
  final TextEditingController _searchController = TextEditingController();
  
  // Use cases
  final _getTransactions = GetTransactions(DI.expenseRepository);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
      _loadTransactions();
    });
  }

  void _loadTransactions() {
    _transactionsFuture = _getTransactions.byMonth(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
      limit: 1000,
    );
  }

  List<TransactionItemData> _filterTransactions(List<TransactionItemData> transactions) {
    var filtered = transactions;

    // Lọc theo loại (Thu nhập/Chi tiêu)
    if (_selectedType != null) {
      filtered = filtered.where((tx) {
        final isIncome = tx.amount.startsWith('+');
        return _selectedType == 'INCOME' ? isIncome : !isIncome;
      }).toList();
    }

    // Lọc theo tìm kiếm
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tx) {
        return tx.title.toLowerCase().contains(_searchQuery) ||
            tx.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Lọc theo danh mục
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where((tx) => tx.category == _selectedCategory).toList();
    }

    // Sắp xếp
    filtered.sort((a, b) {
      switch (_sortOrder) {
        case 'oldest':
          final aDate = a.occurredAt ?? DateTime(1970);
          final bDate = b.occurredAt ?? DateTime(1970);
          return aDate.compareTo(bDate);
        case 'newest':
        default:
          final aDate = a.occurredAt ?? DateTime(1970);
          final bDate = b.occurredAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
      }
    });

    return filtered;
  }


  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedCategory: _selectedCategory,
        sortOrder: _sortOrder,
        onCategoryChanged: (category) {
          setState(() {
            _selectedCategory = category;
          });
          Navigator.pop(context);
        },
        onSortChanged: (sort) {
          setState(() {
            _sortOrder = sort;
          });
          Navigator.pop(context);
        },
        onClearFilters: () {
          setState(() {
            _selectedCategory = null;
            _sortOrder = 'newest';
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả giao dịch'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedCategory != null || _sortOrder != 'newest')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionItemData>?>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTransactions = snapshot.data ?? <TransactionItemData>[];
          final transactions = _filterTransactions(allTransactions);

          // Nhóm giao dịch theo tháng (ở đây chỉ một tháng được chọn)
          final Map<String, List<TransactionItemData>> groupedByMonth = {};
          for (final tx in transactions) {
            final date = tx.occurredAt ?? DateTime.now();
            final monthKey = 'Tháng ${date.month}/${date.year}';
            
            if (!groupedByMonth.containsKey(monthKey)) {
              groupedByMonth[monthKey] = [];
            }
            groupedByMonth[monthKey]!.add(tx);
          }
          
          // Sắp xếp các tháng theo thứ tự giảm dần (tháng gần nhất trước)
          final sortedMonths = groupedByMonth.keys.toList()
            ..sort((a, b) {
              // Parse "Tháng M/YYYY" để so sánh
              final aParts = a.replaceAll('Tháng ', '').split('/');
              final bParts = b.replaceAll('Tháng ', '').split('/');
              if (aParts.length == 2 && bParts.length == 2) {
                final aYear = int.tryParse(aParts[1]) ?? 0;
                final aMonth = int.tryParse(aParts[0]) ?? 0;
                final bYear = int.tryParse(bParts[1]) ?? 0;
                final bMonth = int.tryParse(bParts[0]) ?? 0;
                if (aYear != bYear) return bYear.compareTo(aYear);
                return bMonth.compareTo(aMonth);
              }
              return b.compareTo(a);
            });

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              // Selector tháng/năm
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
              const SizedBox(height: AppSpacing.lg),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc danh mục...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Chip buttons để lọc theo loại
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Tất cả',
                      isSelected: _selectedType == null,
                      onTap: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: 'Thu nhập',
                      isSelected: _selectedType == 'INCOME',
                      onTap: () {
                        setState(() {
                          _selectedType = 'INCOME';
                        });
                      },
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: 'Chi tiêu',
                      isSelected: _selectedType == 'EXPENSE',
                      onTap: () {
                        setState(() {
                          _selectedType = 'EXPENSE';
                        });
                      },
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        allTransactions.isEmpty
                            ? 'Chưa có giao dịch nào'
                            : 'Không tìm thấy giao dịch phù hợp',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.gray500,
                            ),
                      ),
                    ],
                  ),
                )
              else
                ...sortedMonths.map((monthKey) {
                  final entry = MapEntry(monthKey, groupedByMonth[monthKey]!);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...entry.value.map((tx) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: TransactionItem(
                              title: tx.title,
                              category: tx.category,
                              amount: tx.amount,
                              icon: tx.icon,
                              color: tx.color,
                              time: tx.time,
                            ),
                          )),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withValues(alpha: 0.15)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? (color ?? AppColors.primary)
                    : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final String sortOrder;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClearFilters;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.sortOrder,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _selectedCategory;
  late String _sortOrder;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _sortOrder = widget.sortOrder;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final getCurrentUser = GetCurrentUser(DI.authRepository);
      final user = getCurrentUser();
      if (user == null) return;
      
      final getCategories = GetCategories(DI.categoryRepository, user.id);
      final categories = await getCategories();
      
      setState(() {
        _categories = categories.map((cat) => {
          'id': cat.id,
          'name': cat.name,
          'type': cat.type,
          'icon': cat.icon,
          'color': cat.color,
        }).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: widget.onClearFilters,
                child: const Text(
                  'Xóa bộ lọc',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Sắp xếp
          Text(
            'Sắp xếp',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SortOption(
                label: 'Mới nhất',
                value: 'newest',
                isSelected: _sortOrder == 'newest',
                onTap: () {
                  setState(() {
                    _sortOrder = 'newest';
                  });
                  widget.onSortChanged('newest');
                },
              ),
              _SortOption(
                label: 'Cũ nhất',
                value: 'oldest',
                isSelected: _sortOrder == 'oldest',
                onTap: () {
                  setState(() {
                    _sortOrder = 'oldest';
                  });
                  widget.onSortChanged('oldest');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Danh mục
          Text(
            'Danh mục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoadingCategories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _CategoryChip(
                  label: 'Tất cả',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    widget.onCategoryChanged(null);
                  },
                ),
                ..._categories.map((cat) {
                  final name = cat['name'] as String;
                  return _CategoryChip(
                    label: name,
                    isSelected: _selectedCategory == name,
                    onTap: () {
                      setState(() {
                        _selectedCategory = name;
                      });
                      widget.onCategoryChanged(name);
                    },
                  );
                }),
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

