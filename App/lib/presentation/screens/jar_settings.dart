import 'dart:math';

import 'package:expenses/common/theme.dart';
import 'package:expenses/service/jar_service.dart';
import 'package:flutter/material.dart';

class JarSettingsScreen extends StatefulWidget {
  const JarSettingsScreen({super.key});

  @override
  State<JarSettingsScreen> createState() => _JarSettingsScreenState();
}

class _JarSettingsScreenState extends State<JarSettingsScreen> {
  bool _loading = true;
  bool _saving = false;
  List<JarModel> _jars = [];
  final List<String> _deleteIds = [];
  int _newJarCount = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await JarService.fetchJars();
      setState(() {
        _jars = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách hũ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _loading = false);
    }
  }

  void _addJar() {
    setState(() {
      final updated = List<JarModel>.from(_jars);
      updated.add(
        JarModel(
          id: null,
          name: 'Hũ mới ${_newJarCount++}',
          slug: '',
          percentage: 10,
          isActive: true,
          balance: 0,
        ),
      );
      _jars = updated;
    });
  }

  void _removeJar(int index) async {
    final jar = _jars[index];
    if (jar.slug == 'necessities') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa hũ Nhu cầu thiết yếu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        actionsPadding: const EdgeInsets.only(
          right: AppSpacing.lg,
          bottom: AppSpacing.md,
          top: AppSpacing.sm,
        ),
        actionsAlignment: MainAxisAlignment.end,
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa hũ "${jar.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              side: BorderSide(
                color: AppColors.primary,
                width: 1.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        if (jar.id != null) _deleteIds.add(jar.id!);
        final updated = List<JarModel>.from(_jars);
        updated.removeAt(index);
        _jars = updated;
      });
    }
  }

  double _calcTotal(List<JarModel> jars) {
    return jars
        .where((j) => j.slug != 'reserve' && j.isActive)
        .fold<double>(0, (p, e) => p + e.percentage);
  }

  Future<void> _save() async {
    // Kiểm tra tổng % trước khi lưu
    final total = _calcTotal(_jars);
    if (total < 100 || total > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tổng phần trăm phải bằng 100%. Hiện tại: ${total.toStringAsFixed(1)}%'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final balanced = JarService.autoBalance(_jars);
      // Kiểm tra lại sau khi cân bằng
      final balancedTotal = _calcTotal(balanced);
      if ((balancedTotal - 100).abs() > 0.1) {
        throw Exception('Lỗi cân bằng: tổng phần trăm = ${balancedTotal.toStringAsFixed(1)}%');
      }
      
      await JarService.saveJars(current: balanced, deleteIds: _deleteIds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu và cân bằng % các hũ'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: const Text('Thiết lập chung các hũ'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      key: ValueKey('jars-list-${_jars.length}'),
                      itemCount: _jars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final jar = _jars[index];
                        final isEssential = jar.slug == 'necessities';
                        final itemKey = 'jar-${jar.id ?? index}-${jar.percentage}-${jar.name}';
                        
                        return Container(
                          key: ValueKey(itemKey),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.gray100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gray900.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('name-$itemKey'),
                                      initialValue: jar.name,
                                      decoration: const InputDecoration(
                                        labelText: 'Tên hũ',
                                      ),
                                      onChanged: (val) {
                                        final updated = List<JarModel>.from(_jars);
                                        updated[index] = jar.copyWith(name: val);
                                        setState(() {
                                          _jars = updated;
                                        });
                                      },
                                    ),
                                  ),
                                  if (!isEssential)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => _removeJar(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      final next = max(0, jar.percentage - 1).toDouble();
                                      final updated = List<JarModel>.from(_jars);
                                      updated[index] = jar.copyWith(percentage: next);
                                      setState(() {
                                        _jars = updated;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: jar.percentage,
                                      min: 0,
                                      max: isEssential ? 55 : 100,
                                      divisions: isEssential ? 55 : 100,
                                      label: '${jar.percentage.toStringAsFixed(0)}%',
                                      onChanged: (val) {
                                        final updated = List<JarModel>.from(_jars);
                                        updated[index] = jar.copyWith(percentage: val);
                                        setState(() {
                                          _jars = updated;
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      final limit = isEssential ? 55 : 100;
                                      final next = min(limit, jar.percentage + 1).toDouble();
                                      final updated = List<JarModel>.from(_jars);
                                      updated[index] = jar.copyWith(percentage: next);
                                      setState(() {
                                        _jars = updated;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: TextFormField(
                                      key: ValueKey('percent-$itemKey'),
                                      initialValue: jar.percentage.toStringAsFixed(0),
                                      decoration: const InputDecoration(suffixText: '%'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) {
                                        final numVal = double.tryParse(val) ?? jar.percentage;
                                        final limit = isEssential ? 55 : 100;
                                        final clamped = numVal.clamp(0, limit).toDouble();
                                        final updated = List<JarModel>.from(_jars);
                                        updated[index] = jar.copyWith(percentage: clamped);
                                        setState(() {
                                          _jars = updated;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Số dư hiện tại: ${jar.balance.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _addJar,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text(
                              'Thêm hũ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              side: BorderSide(color: AppColors.primary, width: 1.5),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Lưu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.gray900,
                              disabledBackgroundColor: AppColors.gray300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

