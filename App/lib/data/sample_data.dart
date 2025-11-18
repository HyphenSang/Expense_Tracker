import 'package:flutter/material.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/common/theme.dart';

/// Class chứa dữ liệu mẫu cho ứng dụng Expenses
class SampleData {
  /// Số dư tổng hiện tại
  static const String totalBalance = '15,500,000 ₫';

  /// Thu nhập trong tháng
  static const String monthlyIncome = '20,000,000 ₫';

  /// Chi tiêu trong tháng
  static const String monthlyExpense = '4,500,000 ₫';

  /// Tiết kiệm trong tháng
  static const String monthlySaved = '15,500,000 ₫';

  /// Danh sách giao dịch gần đây
  static List<TransactionItemData> get recentTransactions => [
        TransactionItemData(
          title: 'Mua sắm tại Coopmart',
          category: 'Thực phẩm',
          amount: '-850,000 ₫',
          icon: Icons.shopping_cart,
          color: AppColors.error,
          time: 'Hôm nay, 14:30',
        ),
        TransactionItemData(
          title: 'Lương tháng 12',
          category: 'Thu nhập',
          amount: '+20,000,000 ₫',
          icon: Icons.account_balance_wallet,
          color: AppColors.success,
          time: 'Hôm qua, 09:00',
        ),
        TransactionItemData(
          title: 'Xăng xe máy',
          category: 'Giao thông',
          amount: '-150,000 ₫',
          icon: Icons.local_gas_station,
          color: AppColors.warning,
          time: 'Hôm qua, 18:45',
        ),
        TransactionItemData(
          title: 'Netflix Premium',
          category: 'Giải trí',
          amount: '-199,000 ₫',
          icon: Icons.movie,
          color: AppColors.info,
          time: '2 ngày trước, 10:00',
        ),
        TransactionItemData(
          title: 'Cà phê với bạn',
          category: 'Ăn uống',
          amount: '-120,000 ₫',
          icon: Icons.local_cafe,
          color: AppColors.warning,
          time: '2 ngày trước, 15:30',
        ),
        TransactionItemData(
          title: 'Tiền điện tháng 11',
          category: 'Tiện ích',
          amount: '-450,000 ₫',
          icon: Icons.bolt,
          color: AppColors.error,
          time: '3 ngày trước, 08:00',
        ),
        TransactionItemData(
          title: 'Mua sách online',
          category: 'Giáo dục',
          amount: '-320,000 ₫',
          icon: Icons.menu_book,
          color: AppColors.primary,
          time: '4 ngày trước, 20:15',
        ),
        TransactionItemData(
          title: 'Gửi tiết kiệm',
          category: 'Tiết kiệm',
          amount: '-5,000,000 ₫',
          icon: Icons.savings,
          color: AppColors.success,
          time: '5 ngày trước, 14:00',
        ),
        TransactionItemData(
          title: 'Mua quà sinh nhật',
          category: 'Quà tặng',
          amount: '-500,000 ₫',
          icon: Icons.card_giftcard,
          color: AppColors.primary,
          time: '6 ngày trước, 19:30',
        ),
        TransactionItemData(
          title: 'Tiền nước tháng 11',
          category: 'Tiện ích',
          amount: '-85,000 ₫',
          icon: Icons.water_drop,
          color: AppColors.info,
          time: '1 tuần trước, 09:00',
        ),
      ];

  /// Nhãn ngày cho phần giao dịch gần đây
  static String get dateLabel {
    final now = DateTime.now();
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${monthNames[now.month - 1]} ${now.year}';
  }

  /// Dữ liệu 6 hũ tài chính
  static List<JarData> get jars => [
        JarData(
          name: 'Nhu cầu thiết yếu',
          amount: '8,525,000 ₫',
          percentage: '55%',
          icon: Icons.home,
          color: AppColors.error,
          progress: 0.85,
        ),
        JarData(
          name: 'Tiết kiệm dài hạn',
          amount: '1,550,000 ₫',
          percentage: '10%',
          icon: Icons.savings,
          color: AppColors.info,
          progress: 0.90,
        ),
        JarData(
          name: 'Giáo dục',
          amount: '1,550,000 ₫',
          percentage: '10%',
          icon: Icons.school,
          color: AppColors.warning,
          progress: 0.75,
        ),
        JarData(
          name: 'Hưởng thụ',
          amount: '1,550,000 ₫',
          percentage: '10%',
          icon: Icons.celebration,
          color: AppColors.primary,
          progress: 0.60,
        ),
        JarData(
          name: 'Tự do tài chính',
          amount: '1,550,000 ₫',
          percentage: '10%',
          icon: Icons.account_balance_wallet,
          color: AppColors.success,
          progress: 0.50,
        ),
        JarData(
          name: 'Cho đi',
          amount: '775,000 ₫',
          percentage: '5%',
          icon: Icons.favorite,
          color: AppColors.error,
          progress: 0.40,
        ),
      ];
}

/// Class chứa dữ liệu cho một hũ tài chính
class JarData {
  final String name;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final double progress;

  JarData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.progress,
  });
}

