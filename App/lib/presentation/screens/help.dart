import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

/// Màn hình trợ giúp và hỗ trợ với các câu hỏi thường gặp
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Làm thế nào để thêm giao dịch mới?',
      answer:
          'Nhấn vào nút dấu cộng (+) ở thanh điều hướng dưới cùng, sau đó điền thông tin giao dịch (loại, số tiền, danh mục, ghi chú) và nhấn "Lưu".',
    ),
    FAQItem(
      question: 'Làm thế nào để quản lý các ví?',
      answer:
          'Vào tab "Ví" ở thanh điều hướng dưới cùng để xem tất cả các ví của bạn. Bạn có thể thêm ví mới, xem số dư và quản lý các ví hiện có.',
    ),
    FAQItem(
      question: '6 hũ tài chính là gì?',
      answer:
          '6 hũ tài chính giúp bạn phân bổ thu nhập theo tỷ lệ: Nhu cầu thiết yếu (55%), Tiết kiệm dài hạn (10%), Giáo dục (10%), Hưởng thụ (10%), Tự do tài chính (10%), và Cho đi (5%).',
    ),
    FAQItem(
      question: 'Làm thế nào để xem thống kê chi tiêu?',
      answer:
          'Vào tab "Thống kê" ở thanh điều hướng để xem biểu đồ chi tiêu theo tháng, so sánh với tháng trước, và phân tích chi tiêu theo danh mục.',
    ),
    FAQItem(
      question: 'Làm thế nào để lọc giao dịch?',
      answer:
          'Trong màn hình "Tất cả giao dịch", bạn có thể lọc theo tháng/năm, loại giao dịch (Thu nhập/Chi tiêu), tìm kiếm theo tên hoặc danh mục, và sắp xếp theo thời gian.',
    ),
    FAQItem(
      question: 'Làm thế nào để thay đổi thông tin cá nhân?',
      answer:
          'Vào màn hình "Hồ sơ" và nhấn vào "Thông tin cá nhân" để cập nhật tên, email và ảnh đại diện của bạn.',
    ),
    FAQItem(
      question: 'Làm thế nào để đổi mật khẩu?',
      answer:
          'Vào màn hình "Hồ sơ" > "Bảo mật" để thay đổi mật khẩu và quản lý các thiết lập bảo mật khác.',
    ),
    FAQItem(
      question: 'Ứng dụng có hỗ trợ nhiều ngôn ngữ không?',
      answer:
          'Hiện tại ứng dụng hỗ trợ tiếng Việt. Tính năng đa ngôn ngữ sẽ được bổ sung trong các phiên bản sau.',
    ),
    FAQItem(
      question: 'Dữ liệu của tôi có được lưu trữ an toàn không?',
      answer:
          'Có, tất cả dữ liệu của bạn được lưu trữ an toàn trên Supabase với mã hóa và bảo mật cao. Chỉ bạn mới có thể truy cập dữ liệu của mình.',
    ),
    FAQItem(
      question: 'Làm thế nào để đăng xuất?',
      answer:
          'Vào màn hình "Hồ sơ" và nhấn vào "Đăng xuất" ở cuối danh sách. Bạn sẽ được xác nhận trước khi đăng xuất.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trợ giúp & Hỗ trợ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gray900),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Câu hỏi thường gặp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tìm câu trả lời cho các thắc mắc của bạn',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // FAQ List
          ..._faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;
            return _buildFAQItem(faq, index);
          }),

          const SizedBox(height: AppSpacing.xl),

          // Contact section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Liên hệ hỗ trợ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Nếu bạn không tìm thấy câu trả lời, vui lòng liên hệ với chúng tôi qua email:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'support@expensetracker.com',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      childrenPadding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      title: Text(
        faq.question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.gray900,
          fontSize: 15,
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            faq.answer,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

