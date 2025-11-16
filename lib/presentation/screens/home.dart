import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/header.dart';
import 'package:expenses/presentation/widgets/total_balance.dart';
import 'package:expenses/presentation/widgets/quick_stats.dart';
import 'package:expenses/presentation/widgets/jars.dart';
import 'package:expenses/presentation/widgets/reminder_banner.dart';
import 'package:expenses/presentation/widgets/b_acc.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/presentation/widgets/bot_nav.dart';
import 'package:expenses/presentation/screens/all_transactions_screen.dart';
import 'package:expenses/presentation/screens/analytics_screen.dart';
import 'package:expenses/presentation/screens/profile_screen.dart';
import 'package:expenses/presentation/screens/wallets_screen.dart';
import 'package:expenses/presentation/screens/add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Home - đã ở đây rồi
        break;
      case 1:
        // Wallets
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WalletsScreen(),
          ),
        ).then((_) {
          // Reset index khi quay lại
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
      case 2:
        // Add transaction (center button)
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          ).then((_) {
            // Reset index khi quay lại
            if (mounted) {
              setState(() {
                _currentIndex = 0;
              });
            }
          });
        } catch (e) {
          debugPrint('Lỗi khi navigate đến AddTransactionScreen: $e');
        }
        break;
      case 3:
        // Analytics
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnalyticsScreen(),
          ),
        ).then((_) {
          // Reset index khi quay lại
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
      case 4:
        // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        ).then((_) {
          // Reset index khi quay lại
          setState(() {
            _currentIndex = 0;
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section với Profile và Icons
            const HomeHeader(),

            // Total Balance Section
            const TotalBalanceSection(balance: '100,000,000 ₫'),

            // Quick Stats
            const QuickStatsSection(
              income: '+15,000,000 ₫',
              expense: '-8,500,000 ₫',
              saved: '+6,500,000 ₫',
            ),

            // 6 Hũ Section - Trọng tâm của app
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SixJarsSection(),
                    const SizedBox(height: AppSpacing.xl),
                    ReminderBanner(
                      message:
                          'Hũ "Tự do tài chính" của bạn đang ở mức thấp. Hãy cố gắng tiết kiệm thêm 2,000,000 ₫ trong tháng này!',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const BankAccountSection(
                      bankName: 'Vietcombank',
                      accountNumber: '****1234',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RecentTransactionsSection(
                      dateLabel: 'Today',
                      transactions: [
                        TransactionItemData(
                          title: 'Lương tháng 12',
                          category: 'Thu nhập',
                          amount: '+15,000,000 ₫',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.success,
                          time: 'Hôm nay',
                        ),
                        TransactionItemData(
                          title: 'Grab Food',
                          category: 'Nhu cầu thiết yếu',
                          amount: '-150,000 ₫',
                          icon: Icons.restaurant,
                          color: AppColors.error,
                          time: 'Hôm nay',
                        ),
                        TransactionItemData(
                          title: 'Mua sách',
                          category: 'Giáo dục',
                          amount: '-250,000 ₫',
                          icon: Icons.school,
                          color: AppColors.warning,
                          time: 'Hôm qua',
                        ),
                      ],
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllTransactionsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
