import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/expense_service.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';

/// Màn hình xem tất cả giao dịch, sắp xếp theo ngày (gần nhất ở trên).
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả giao dịch'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<TransactionItemData>>(
        future: ExpenseService.getRecentTransactions(limit: 1000), // Lấy tất cả
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Chưa có giao dịch nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
            );
          }

          // Nhóm giao dịch theo tháng (sắp xếp theo ngày, gần nhất ở trên)
          final Map<String, List<TransactionItemData>> groupedByMonth = {};
          for (final tx in transactions) {
            final date = tx.occurredAt ?? DateTime.now();
            final monthKey = 'Tháng ${date.month}/${date.year}';
            
            if (!groupedByMonth.containsKey(monthKey)) {
              groupedByMonth[monthKey] = [];
            }
            groupedByMonth[monthKey]!.add(tx);
          }
          
          // Sắp xếp các tháng theo thứ tự giảm dần (tháng gần nhất trước)
          final sortedMonths = groupedByMonth.keys.toList()
            ..sort((a, b) {
              // Parse "Tháng M/YYYY" để so sánh
              final aParts = a.replaceAll('Tháng ', '').split('/');
              final bParts = b.replaceAll('Tháng ', '').split('/');
              if (aParts.length == 2 && bParts.length == 2) {
                final aYear = int.tryParse(aParts[1]) ?? 0;
                final aMonth = int.tryParse(aParts[0]) ?? 0;
                final bYear = int.tryParse(bParts[1]) ?? 0;
                final bMonth = int.tryParse(bParts[0]) ?? 0;
                if (aYear != bYear) return bYear.compareTo(aYear);
                return bMonth.compareTo(aMonth);
              }
              return b.compareTo(a);
            });

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              ...sortedMonths.map((monthKey) {
                final entry = MapEntry(monthKey, groupedByMonth[monthKey]!);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...entry.value.map((tx) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TransactionItem(
                            title: tx.title,
                            category: tx.category,
                            amount: tx.amount,
                            icon: tx.icon,
                            color: tx.color,
                            time: tx.time,
                          ),
                        )),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

