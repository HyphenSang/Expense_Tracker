import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/category.dart';
import 'package:expenses/domain/features/jar.dart';
import 'package:expenses/domain/entities/category.dart';
import 'package:expenses/presentation/screens/create_category.dart';

/// Màn hình quản lý danh mục
class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends State<CategoriesManagementScreen> {
  Future<List<CategoryEntity>>? _categoriesFuture;
  String _selectedType = 'EXPENSE'; // 'EXPENSE' hoặc 'INCOME'
  final _getCurrentUser = GetCurrentUser(DI.authRepository);
  Map<String, String> _jarNames = {}; // Map jar_id -> jar_name

  @override
  void initState() {
    super.initState();
    _loadJars();
    _loadCategories();
  }

  Future<void> _loadJars() async {
    final user = _getCurrentUser();
    if (user == null) return;

    try {
      final getJars = GetJars(DI.jarRepository, user.id);
      final jars = await getJars();
      setState(() {
        _jarNames = {
          for (var jar in jars) jar.id: jar.name,
        };
      });
    } catch (e) {
      // Ignore errors
    }
  }

  void _loadCategories() {
    final user = _getCurrentUser();
    if (user != null) {
      final getCategories = GetCategories(DI.categoryRepository, user.id);
      setState(() {
        _categoriesFuture = getCategories(type: _selectedType);
      });
    }
  }

  Future<void> _openAddCategory() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCategoryScreen(
          initialIsExpense: _selectedType == 'EXPENSE',
        ),
      ),
    );

    if (result != null) {
      _loadCategories();
    }
  }

  Future<void> _openEditCategory(CategoryEntity category) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCategoryScreen(
          initialIsExpense: category.type == 'EXPENSE',
          category: category,
        ),
      ),
    );

    if (result != null) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deleteCategory = DeleteCategory(DI.categoryRepository);
        await deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa danh mục "${category.name}"'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể xóa danh mục: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return AppColors.gray500;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.gray500;
    }
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category;
    }
    try {
      final codePoint = int.tryParse(iconName.split(':').first);
      if (codePoint != null) {
        return IconData(codePoint, fontFamily: 'MaterialIcons');
      }
    } catch (e) {
      // Fallback
    }
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh mục'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Type selector
            Container(
              margin: const EdgeInsets.all(AppSpacing.xl),
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
                          _selectedType = 'EXPENSE';
                        });
                        _loadCategories();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _selectedType == 'EXPENSE' ? AppColors.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: _selectedType == 'EXPENSE' ? AppColors.gray900 : AppColors.gray400,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Chi tiêu',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedType == 'EXPENSE' ? AppColors.gray900 : AppColors.gray400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = 'INCOME';
                        });
                        _loadCategories();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _selectedType == 'INCOME' ? AppColors.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: _selectedType == 'INCOME' ? AppColors.gray900 : AppColors.gray400,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Thu nhập',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedType == 'INCOME' ? AppColors.gray900 : AppColors.gray400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header với nút thêm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách (${_selectedType == 'EXPENSE' ? 'Chi tiêu' : 'Thu nhập'})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _openAddCategory,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Thêm mới'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Categories list
            Expanded(
              child: FutureBuilder<List<CategoryEntity>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Có lỗi xảy ra: ${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.gray600,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: _loadCategories,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Chưa có danh mục nào',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.gray500,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: _openAddCategory,
                            icon: const Icon(Icons.add),
                            label: const Text('Tạo danh mục đầu tiên'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final color = _parseColor(category.color);
                      final icon = _getIconData(category.icon);

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.radiusLG,
                          border: Border.all(
                            color: AppColors.gray200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray900,
                                        ),
                                  ),
                                  if (category.type == 'EXPENSE' && category.jarId != null) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _jarNames[category.jarId] ?? 'Hũ không xác định',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.gray500,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openEditCategory(category);
                                } else if (value == 'delete') {
                                  _deleteCategory(category);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: AppSpacing.sm),
                                      Text('Chỉnh sửa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: AppColors.error),
                                      SizedBox(width: AppSpacing.sm),
                                      Text('Xóa', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

