import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  // Dữ liệu fake - Group theo ngày
  static Map<String, List<TransactionItemData>> _getFakeTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    return {
      _formatDateKey(today): [
        TransactionItemData(
          title: 'Lương tháng 12',
          category: 'Thu nhập',
          amount: '+15,000,000 ₫',
          icon: Icons.account_balance_wallet,
          color: AppColors.success,
          time: '09:30',
        ),
        TransactionItemData(
          title: 'Grab Food',
          category: 'Nhu cầu thiết yếu',
          amount: '-150,000 ₫',
          icon: Icons.restaurant,
          color: AppColors.error,
          time: '12:45',
        ),
        TransactionItemData(
          title: 'Xăng xe',
          category: 'Di chuyển',
          amount: '-500,000 ₫',
          icon: Icons.local_gas_station,
          color: AppColors.error,
          time: '18:20',
        ),
        TransactionItemData(
          title: 'Cà phê',
          category: 'Giải trí',
          amount: '-80,000 ₫',
          icon: Icons.coffee,
          color: AppColors.warning,
          time: '14:15',
        ),
      ],
      _formatDateKey(yesterday): [
        TransactionItemData(
          title: 'Mua sách',
          category: 'Giáo dục',
          amount: '-250,000 ₫',
          icon: Icons.school,
          color: AppColors.warning,
          time: '10:00',
        ),
        TransactionItemData(
          title: 'Netflix',
          category: 'Giải trí',
          amount: '-180,000 ₫',
          icon: Icons.movie,
          color: AppColors.info,
          time: '20:30',
        ),
        TransactionItemData(
          title: 'Tiền điện',
          category: 'Nhu cầu thiết yếu',
          amount: '-350,000 ₫',
          icon: Icons.electrical_services,
          color: AppColors.error,
          time: '08:00',
        ),
      ],
      _formatDateKey(twoDaysAgo): [
        TransactionItemData(
          title: 'Freelance Project',
          category: 'Thu nhập',
          amount: '+5,000,000 ₫',
          icon: Icons.work,
          color: AppColors.success,
          time: '15:00',
        ),
        TransactionItemData(
          title: 'Siêu thị',
          category: 'Nhu cầu thiết yếu',
          amount: '-1,200,000 ₫',
          icon: Icons.shopping_cart,
          color: AppColors.error,
          time: '19:00',
        ),
        TransactionItemData(
          title: 'Gym',
          category: 'Sức khỏe',
          amount: '-300,000 ₫',
          icon: Icons.fitness_center,
          color: AppColors.info,
          time: '07:00',
        ),
      ],
      _formatDateKey(threeDaysAgo): [
        TransactionItemData(
          title: 'Quà sinh nhật',
          category: 'Quà tặng',
          amount: '-800,000 ₫',
          icon: Icons.card_giftcard,
          color: AppColors.warning,
          time: '16:30',
        ),
        TransactionItemData(
          title: 'Uber',
          category: 'Di chuyển',
          amount: '-120,000 ₫',
          icon: Icons.directions_car,
          color: AppColors.error,
          time: '21:00',
        ),
      ],
    };
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(dateOnly).inDays;
    
    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else if (difference < 7) {
      final weekdays = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
      return weekdays[date.weekday % 7];
    } else {
      final months = [
        'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _getFakeTransactions();
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => _parseDateKey(b).compareTo(_parseDateKey(a)));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tất cả giao dịch'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final dateKey = sortedDates[index];
          final date = _parseDateKey(dateKey);
          final transactions = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Padding(
                padding: EdgeInsets.only(
                  top: index > 0 ? AppSpacing.xl : 0,
                  bottom: AppSpacing.md,
                ),
                child: Text(
                  _formatDateGroup(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                ),
              ),
              // Transactions for this date
              ...transactions.map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: TransactionItem(
                    title: transaction.title,
                    category: transaction.category,
                    amount: transaction.amount,
                    icon: transaction.icon,
                    color: transaction.color,
                    time: transaction.time,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

