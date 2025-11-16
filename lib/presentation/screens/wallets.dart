import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  // Dữ liệu fake cho wallets
  static List<WalletData> _getFakeWallets() {
    return [
      WalletData(
        name: 'Ví tiền mặt',
        type: 'Tiền mặt',
        balance: 5000000,
        icon: Icons.wallet,
        color: AppColors.primary,
      ),
      WalletData(
        name: 'Vietcombank',
        type: 'Ngân hàng',
        balance: 45000000,
        accountNumber: '****1234',
        icon: Icons.account_balance,
        color: AppColors.info,
      ),
      WalletData(
        name: 'Techcombank',
        type: 'Ngân hàng',
        balance: 30000000,
        accountNumber: '****5678',
        icon: Icons.account_balance,
        color: AppColors.success,
      ),
      WalletData(
        name: 'Ví điện tử MoMo',
        type: 'Ví điện tử',
        balance: 2000000,
        icon: Icons.account_balance_wallet,
        color: AppColors.warning,
      ),
      WalletData(
        name: 'ZaloPay',
        type: 'Ví điện tử',
        balance: 500000,
        icon: Icons.payment,
        color: AppColors.error,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final wallets = _getFakeWallets();
    final totalBalance = wallets.fold<double>(
      0,
      (sum, wallet) => sum + wallet.balance,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ví & Tài khoản'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Total Balance Card
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusXL,
                boxShadow: AppShadows.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng số dư',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatCurrency(totalBalance),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.gray700,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          '${wallets.length} ví & tài khoản',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray700,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Wallets List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _WalletCard(wallet: wallet),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add wallet screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.gray900,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    return '$formatted ₫';
  }
}

class WalletData {
  final String name;
  final String type;
  final double balance;
  final String? accountNumber;
  final IconData icon;
  final Color color;

  WalletData({
    required this.name,
    required this.type,
    required this.balance,
    this.accountNumber,
    required this.icon,
    required this.color,
  });
}

class _WalletCard extends StatelessWidget {
  final WalletData wallet;

  const _WalletCard({required this.wallet});

  String _formatCurrency(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ',$formatted';
        count = 0;
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    return '$formatted ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.gray200),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          // Wallet Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: wallet.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMD,
            ),
            child: Icon(
              wallet.icon,
              color: wallet.color,
              size: AppIconSizes.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Wallet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        wallet.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (wallet.accountNumber != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          wallet.accountNumber!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Balance
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatCurrency(wallet.balance),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

