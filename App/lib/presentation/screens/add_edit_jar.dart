import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/jar.dart';
import 'package:expenses/domain/entities/jar.dart';

class AddEditJarScreen extends StatefulWidget {
  final JarEntity? jar; 

  const AddEditJarScreen({super.key, this.jar});

  @override
  State<AddEditJarScreen> createState() => _AddEditJarScreenState();
}

class _AddEditJarScreenState extends State<AddEditJarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _percentageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  String? _selectedColor;
  String? _selectedIcon;
  bool _isSaving = false;

  // Use cases
  final _getCurrentUser = GetCurrentUser(DI.authRepository);

  final List<String> _availableColors = [
    '#EF4444', // Đỏ
    '#3B82F6', // Xanh dương
    '#F59E0B', // Cam
    '#8B5CF6', // Tím
    '#10B981', // Xanh lá
    '#EC4899', // Hồng
    '#6B7280', // Xám
  ];

  final List<String> _availableIcons = [
    'home',
    'savings',
    'school',
    'celebration',
    'account_balance_wallet',
    'favorite',
    'work',
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'fitness_center',
    'book',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.jar != null) {
      // Chế độ chỉnh sửa
      _nameController.text = widget.jar!.name;
      _slugController.text = widget.jar!.slug;
      _percentageController.text = widget.jar!.percentage.round().toString();
      _descriptionController.text = widget.jar!.description ?? '';
      _targetAmountController.text = widget.jar!.targetAmount?.toString() ?? '';
      _selectedColor = widget.jar!.color;
      _selectedIcon = widget.jar!.icon;
    } else {
      // Chế độ tạo mới - set default
      _selectedColor = _availableColors[0];
      _selectedIcon = _availableIcons[0];
    }
    _nameController.addListener(_updateSlugFromName);
  }

  void _updateSlugFromName() {
    if (widget.jar == null) {
      // Chỉ tự động generate slug khi tạo mới
      final name = _nameController.text.trim().toLowerCase();
      final slug = name
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'-+'), '_');
      if (slug.isNotEmpty) {
        _slugController.text = slug;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _percentageController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveJar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final slug = _slugController.text.trim();
      final percentage = int.tryParse(_percentageController.text) ?? 0;
      final description = _descriptionController.text.trim();
      final targetAmount = _targetAmountController.text.trim().isEmpty
          ? null
          : double.tryParse(_targetAmountController.text.replaceAll('.', ''));

      if (percentage < 0 || percentage > 100) {
        throw StateError('Phần trăm phải từ 0 đến 100');
      }

      final user = _getCurrentUser();
      if (user == null) {
        throw StateError('Chưa đăng nhập');
      }

      if (widget.jar == null) {
        // Tạo mới
        final createJar = CreateJar(DI.jarRepository, user.id);
        await createJar(
          name: name,
          slug: slug,
          percentage: percentage,
          icon: _selectedIcon,
          color: _selectedColor,
          description: description.isEmpty ? null : description,
          targetAmount: targetAmount,
        );
      } else {
        // Cập nhật
        final updateJar = UpdateJar(DI.jarRepository);
        await updateJar(
          jarId: widget.jar!.id,
          name: name,
          slug: slug,
          percentage: percentage,
          icon: _selectedIcon,
          color: _selectedColor,
          description: description.isEmpty ? null : description,
          targetAmount: targetAmount,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true); // Trả về true để refresh

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.jar == null
              ? 'Đã tạo hũ thành công'
              : 'Đã cập nhật hũ thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể lưu hũ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'savings':
        return Icons.savings;
      case 'school':
        return Icons.school;
      case 'celebration':
        return Icons.celebration;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'favorite':
        return Icons.favorite;
      case 'work':
        return Icons.work;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.jar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa hũ' : 'Tạo hũ mới'),
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
                // Icon và màu sắc
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _parseColor(_selectedColor)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(_selectedIcon),
                          color: _parseColor(_selectedColor),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _availableColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _parseColor(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.gray900
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl * 2),

                // Tên hũ
                Text(
                  'Tên hũ *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên hũ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên hũ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Slug
                Text(
                  'Mã định danh (slug) *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    hintText: 'ví_dụ_như_này',
                    helperText: 'Dùng để định danh hũ (chỉ chữ thường, số và dấu gạch dưới)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã định danh';
                    }
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                      return 'Mã định danh chỉ được chứa chữ thường, số và dấu gạch dưới';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Phần trăm
                Text(
                  'Phần trăm phân bổ (%) *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _percentageController,
                  decoration: const InputDecoration(
                    hintText: '0-100',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập phần trăm';
                    }
                    final percentage = int.tryParse(value);
                    if (percentage == null || percentage < 0 || percentage > 100) {
                      return 'Phần trăm phải từ 0 đến 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Mô tả
                Text(
                  'Mô tả',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mô tả (tùy chọn)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Số tiền mục tiêu
                Text(
                  'Số tiền mục tiêu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    hintText: '0',
                    helperText: 'Số tiền mục tiêu cho hũ này (tùy chọn)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl * 2),

                // Nút lưu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveJar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.gray900,
                    ),
                    child: Text(
                      _isSaving
                          ? 'Đang lưu...'
                          : (isEdit ? 'Cập nhật' : 'Tạo mới'),
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

