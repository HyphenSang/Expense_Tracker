import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/expense.dart';
import 'package:expenses/domain/repositories/expense.dart' as domain_expense;
import 'package:expenses/presentation/screens/add_wallet.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/expense.dart';
import 'package:expenses/domain/features/wallet.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/entities/wallet.dart';

/// Màn hình ví & tài khoản thanh toán.
///
/// Hiện sử dụng dữ liệu mẫu từ [SampleData] để minh hoạ UI,
/// sau này có thể map với bảng `wallets` trong database.
class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  Future<List<WalletInfo>>? _walletsFuture;
  Future<List<WalletEntity>>? _allWalletsFuture;

  // Use cases
  final _getWallets = GetWallets(DI.expenseRepository);
  final _getSummary = GetExpenseSummary(DI.expenseRepository);
  final _getCurrentUser = GetCurrentUser(DI.authRepository);

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  void _loadWallets() {
    setState(() {
      _walletsFuture = _getWallets();
      final user = _getCurrentUser();
      if (user != null) {
        final getAllWallets = GetAllWallets(DI.walletRepository, user.id);
        _allWalletsFuture = getAllWallets();
      }
    });
  }

  Future<void> _openAddWallet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddWalletScreen(),
      ),
    );

    // Nếu thêm thành công, refresh danh sách
    if (result == true) {
      _loadWallets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<WalletInfo>>(
        future: _walletsFuture,
        builder: (context, snapshot) {
          final wallets = snapshot.data ?? const <WalletInfo>[];

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ví & Tài khoản',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Quản lý các ví tiền mặt, tài khoản ngân hàng và số dư hiện tại.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.gray500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _WalletSummaryCard(
                wallets: wallets,
                getSummary: _getSummary,
                allWalletsFuture: _allWalletsFuture,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách ví',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _openAddWallet,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Thêm mới'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FutureBuilder<List<WalletEntity>>(
                future: _allWalletsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final allWallets = snapshot.data ?? [];
                  return _WalletList(
                    wallets: allWallets,
                    onToggleActive: (walletId, isActive) async {
                      final updateWalletStatus = UpdateWalletStatus(DI.walletRepository);
                      await updateWalletStatus(
                        walletId: walletId,
                        isActive: isActive,
                      );
                      _loadWallets();
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WalletSummaryCard extends StatelessWidget {
  final List<WalletInfo> wallets;
  final GetExpenseSummary getSummary;
  final Future<List<WalletEntity>>? allWalletsFuture;

  const _WalletSummaryCard({
    required this.wallets,
    required this.getSummary,
    this.allWalletsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<domain_expense.ExpenseSummary>(
      future: getSummary.call(),
      builder: (context, snapshot) {
        final total = snapshot.data?.totalBalance ?? '—';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.radiusXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng số dư',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                total,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FutureBuilder<List<WalletEntity>>(
                future: allWalletsFuture,
                builder: (context, snapshot) {
                  final activeCount = snapshot.data?.where((w) => w.isActive == true).length ?? wallets.length;
                  return Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$activeCount ví đang hoạt động',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray700,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletList extends StatelessWidget {
  final List<WalletEntity> wallets;
  final Function(String walletId, bool isActive) onToggleActive;

  const _WalletList({
    required this.wallets,
    required this.onToggleActive,
  });

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

  String _formatCurrency(num value) {
    // Định dạng đầy đủ theo kiểu Việt Nam với dấu chấm phân cách hàng nghìn
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

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Chưa có ví nào',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: wallets
          .map(
            (w) {
              final isActive = w.isActive;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : AppColors.gray50,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(
                    color: isActive ? AppColors.gray200 : AppColors.gray300,
                    width: isActive ? 1 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.gray100 : AppColors.gray200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: isActive ? AppColors.secondary : AppColors.gray400,
                        size: AppIconSizes.sm,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? AppColors.gray900 : AppColors.gray500,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            w.bankName ?? _getTypeLabel(w.type),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray500,
                                ),
                          ),
                          if (!isActive) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Không hoạt động',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.gray600,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(w.balance),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppColors.gray900 : AppColors.gray500,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            onToggleActive(w.id, value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
          .toList(),
    );
  }
}

