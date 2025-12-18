import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/expense_service.dart';
import 'package:expenses/presentation/screens/add_wallet.dart';

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

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  void _loadWallets() {
    setState(() {
      _walletsFuture = ExpenseService.getWallets();
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
                  IconButton(
                    onPressed: _openAddWallet,
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 28,
                    color: AppColors.primary,
                    tooltip: 'Thêm ví/tài khoản',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _WalletSummaryCard(wallets: wallets),
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
              _WalletList(wallets: wallets),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
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

  const _WalletSummaryCard({required this.wallets});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExpenseSummary>(
      future: ExpenseService.getSummary(),
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
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${wallets.length} ví đang hoạt động',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletList extends StatelessWidget {
  final List<WalletInfo> wallets;

  const _WalletList({required this.wallets});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: wallets
          .map(
            (w) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.secondary,
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
                                color: AppColors.gray900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          w.bankName ?? _getTypeLabel(w.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    w.balanceFormatted,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

