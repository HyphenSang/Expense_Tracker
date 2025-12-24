import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/wallet.dart';

/// Màn hình thêm ví hoặc tài khoản ngân hàng.
class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'CASH'; // CASH, BANK, CARD, EWALLET
  String? _selectedBank;
  bool _isCreating = false;

  // Danh sách ngân hàng fake
  final List<Map<String, String>> _banks = [
    {'code': 'VCB', 'name': 'Vietcombank', 'shortName': 'VCB'},
    {'code': 'BIDV', 'name': 'BIDV', 'shortName': 'BIDV'},
    {'code': 'TCB', 'name': 'Techcombank', 'shortName': 'TCB'},
    {'code': 'ACB', 'name': 'ACB', 'shortName': 'ACB'},
    {'code': 'VIB', 'name': 'VIB', 'shortName': 'VIB'},
    {'code': 'TPB', 'name': 'TPBank', 'shortName': 'TPB'},
    {'code': 'VPB', 'name': 'VPBank', 'shortName': 'VPB'},
    {'code': 'MSB', 'name': 'MSB', 'shortName': 'MSB'},
    {'code': 'HDB', 'name': 'HDBank', 'shortName': 'HDB'},
    {'code': 'SHB', 'name': 'SHB', 'shortName': 'SHB'},
    {'code': 'OCB', 'name': 'OCB', 'shortName': 'OCB'},
    {'code': 'MBB', 'name': 'MB Bank', 'shortName': 'MBB'},
    {'code': 'STB', 'name': 'Sacombank', 'shortName': 'STB'},
    {'code': 'VAB', 'name': 'VietABank', 'shortName': 'VAB'},
    {'code': 'NAB', 'name': 'Nam A Bank', 'shortName': 'NAB'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _createWallet() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate thêm
    if (_selectedType == 'BANK' && _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngân hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Parse số dư ban đầu
      num initialBalance = 0;
      if (_balanceController.text.trim().isNotEmpty) {
        final balanceStr = _balanceController.text.replaceAll('.', '');
        initialBalance = num.tryParse(balanceStr) ?? 0;
      }

      // Lấy tên ngân hàng nếu có
      String? bankName;
      if (_selectedType == 'BANK' && _selectedBank != null) {
        final bank = _banks.firstWhere(
          (b) => b['code'] == _selectedBank,
          orElse: () => {'name': _selectedBank!},
        );
        bankName = bank['name'];
      }

      await WalletService.createWallet(
        name: _nameController.text.trim(),
        type: _selectedType,
        bankName: bankName,
        accountNumber: _accountNumberController.text.trim().isEmpty
            ? null
            : _accountNumberController.text.trim(),
        initialBalance: initialBalance,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true); // Trả về true để refresh

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo ví/tài khoản thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo ví/tài khoản: $e'),
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'CASH':
        return 'Ví tiền mặt';
      case 'BANK':
        return 'Tài khoản ngân hàng';
      case 'CARD':
        return 'Thẻ tín dụng';
      case 'EWALLET':
        return 'Ví điện tử';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'CASH':
        return Icons.account_balance_wallet;
      case 'BANK':
        return Icons.account_balance;
      case 'CARD':
        return Icons.credit_card;
      case 'EWALLET':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm ví/tài khoản'),
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
                // Loại ví/tài khoản
                Text(
                  'Loại ví/tài khoản',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: ['CASH', 'BANK', 'CARD', 'EWALLET'].map((type) {
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                          if (type != 'BANK') {
                            _selectedBank = null;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(type),
                              color: isSelected
                                  ? AppColors.gray900
                                  : AppColors.gray600,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _getTypeLabel(type),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.gray900
                                    : AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Chọn ngân hàng (chỉ hiện khi chọn BANK)
                if (_selectedType == 'BANK') ...[
                  Text(
                    'Ngân hàng*',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(
                      hintText: 'Chọn ngân hàng',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    items: _banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['code'],
                        child: Text(bank['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBank = value;
                      });
                    },
                    validator: (value) {
                      if (_selectedType == 'BANK' && value == null) {
                        return 'Vui lòng chọn ngân hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Tên ví/tài khoản
                Text(
                  'Tên ví/tài khoản*',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: _selectedType == 'BANK'
                        ? 'Ví dụ: Tài khoản chính'
                        : 'Ví dụ: Ví tiền mặt',
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên ví/tài khoản';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Số tài khoản (tùy chọn)
                if (_selectedType == 'BANK') ...[
                  Text(
                    'Số tài khoản (tùy chọn)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập số tài khoản',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Số dư ban đầu (tùy chọn)
                Text(
                  'Số dư ban đầu (tùy chọn)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                    prefixText: '₫ ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    _ThousandSeparatorFormatter(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl * 2),

                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.gray900,
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

/// Format số nguyên sang chuỗi có dấu chấm ngăn cách hàng nghìn.
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reversedIndex = text.length - i - 1;
      buffer.write(text[i]);
      final isThousand = reversedIndex % 3 == 0 && i != text.length - 1;
      if (isThousand) buffer.write('.');
    }
    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


