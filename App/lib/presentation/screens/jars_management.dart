import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/jar.dart';
import 'package:expenses/domain/entities/jar.dart';
import 'package:expenses/presentation/screens/add_edit_jar.dart';

/// Màn hình quản lý hũ tài chính
class JarsManagementScreen extends StatefulWidget {
  const JarsManagementScreen({super.key});

  @override
  State<JarsManagementScreen> createState() => _JarsManagementScreenState();
}

class _JarsManagementScreenState extends State<JarsManagementScreen> {
  Future<List<JarEntity>>? _jarsFuture;
  final _getCurrentUser = GetCurrentUser(DI.authRepository);

  @override
  void initState() {
    super.initState();
    _loadJars();
  }

  void _loadJars() {
    final user = _getCurrentUser();
    if (user != null) {
      final getAllJars = GetAllJars(DI.jarRepository, user.id);
      setState(() {
        _jarsFuture = getAllJars();
      });
    }
  }

  Future<void> _openAddJar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditJarScreen(),
      ),
    );

    if (result == true) {
      _loadJars();
    }
  }

  Future<void> _openEditJar(JarEntity jar) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditJarScreen(jar: jar),
      ),
    );

    if (result == true) {
      _loadJars();
    }
  }

  Future<void> _deleteJar(JarEntity jar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa hũ "${jar.name}"?'),
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
        final deleteJar = DeleteJar(DI.jarRepository);
        await deleteJar(jar.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa hũ "${jar.name}"'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadJars();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể xóa hũ: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String _formatCurrency(num value) {
    final intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final reversedIndex = str.length - i - 1;
      buffer.write(str[i]);
      final isThousand = reversedIndex % 3 == 0 && i != str.length - 1;
      if (isThousand) buffer.write('.');
    }
    return '${buffer.toString()} ₫';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Hũ Tài Chính'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<JarEntity>>(
          future: _jarsFuture,
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
                      onPressed: _loadJars,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final jars = snapshot.data ?? [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách hũ (${jars.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: _openAddJar,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Thêm mới'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: jars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: AppColors.gray400,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Chưa có hũ nào',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.gray500,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton.icon(
                                onPressed: _openAddJar,
                                icon: const Icon(Icons.add),
                                label: const Text('Tạo hũ đầu tiên'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          itemCount: jars.length,
                          itemBuilder: (context, index) {
                            final jar = jars[index];
                            final color = _parseColor(jar.color);

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: jar.isActive
                                    ? Colors.white
                                    : AppColors.gray50,
                                borderRadius: AppRadius.radiusLG,
                                border: Border.all(
                                  color: jar.isActive
                                      ? AppColors.gray200
                                      : AppColors.gray300,
                                  width: jar.isActive ? 1 : 1.5,
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
                                      Icons.account_balance_wallet,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                jar.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: jar.isActive
                                                          ? AppColors.gray900
                                                          : AppColors.gray500,
                                                    ),
                                              ),
                                            ),
                                            if (!jar.isActive)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.sm,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.gray300,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Không hoạt động',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.gray600,
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          '${jar.percentage.toStringAsFixed(0)}% • ${_formatCurrency(jar.balance)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.gray500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _openEditJar(jar);
                                      } else if (value == 'delete') {
                                        _deleteJar(jar);
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
                                            Icon(Icons.delete,
                                                size: 20,
                                                color: AppColors.error),
                                            SizedBox(width: AppSpacing.sm),
                                            Text('Xóa',
                                                style: TextStyle(
                                                    color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

