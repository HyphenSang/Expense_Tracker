import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để tạo giao dịch mới cho người dùng hiện tại.
///
/// Insert vào bảng `transactions` với các cột:
/// - user_id (uuid)
/// - wallet_id (uuid) - ví đầu tiên của user hoặc ví mặc định
/// - category_id (uuid) - tìm hoặc tạo category từ categoryName
/// - type ('EXPENSE' hoặc 'INCOME')
/// - amount (numeric)
/// - note (text)
/// - occurred_at (timestamptz)
class TransactionService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static User? get _currentUser => _client.auth.currentUser;

  /// Lấy hoặc tạo category từ tên danh mục.
  static Future<String> _getOrCreateCategory({
    required String userId,
    required String categoryName,
    required String type, // 'EXPENSE' hoặc 'INCOME'
  }) async {
    // Tìm category đã tồn tại
    final existing = await _client
        .from('categories')
        .select('id')
        .eq('user_id', userId)
        .eq('name', categoryName)
        .eq('type', type)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Tạo category mới
    final newCategory = await _client
        .from('categories')
        .insert({
          'user_id': userId,
          'name': categoryName,
          'type': type,
          'is_system': false,
        })
        .select('id')
        .single();

    return newCategory['id'] as String;
  }

  /// Lấy ví đầu tiên của user hoặc tạo ví mặc định.
  static Future<String> _getOrCreateDefaultWallet({
    required String userId,
  }) async {
    // Tìm ví đầu tiên đang hoạt động
    final existing = await _client
        .from('wallets')
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Tạo ví mặc định nếu chưa có
    final newWallet = await _client
        .from('wallets')
        .insert({
          'user_id': userId,
          'name': 'Ví tiền mặt',
          'type': 'CASH',
          'balance': 0,
          'is_active': true,
        })
        .select('id')
        .single();

    return newWallet['id'] as String;
  }

  /// Tạo giao dịch mới.
  static Future<void> createTransaction({
    required bool isExpense,
    required int amount,
    required String categoryName,
    required DateTime occurredAt,
    String? note,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tạo giao dịch.');
    }

    // Lấy hoặc tạo category
    final categoryId = await _getOrCreateCategory(
      userId: user.id,
      categoryName: categoryName,
      type: isExpense ? 'EXPENSE' : 'INCOME',
    );

    // Lấy hoặc tạo wallet
    final walletId = await _getOrCreateDefaultWallet(userId: user.id);

    // Đọc số dư hiện tại TRƯỚC khi insert transaction để đảm bảo tính đúng
    final wallet = await _client
        .from('wallets')
        .select('balance')
        .eq('id', walletId)
        .single();
    
    final currentBalance = (wallet['balance'] as num?) ?? 0;
    
    // Tính số dư mới: tăng cho INCOME, giảm cho EXPENSE
    final newBalance = isExpense 
        ? currentBalance - amount  // Chi tiêu: trừ đi
        : currentBalance + amount; // Thu nhập: cộng vào
    
    // Insert transaction
    final transactionResult = await _client.from('transactions').insert({
      'user_id': user.id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': isExpense ? 'EXPENSE' : 'INCOME',
      'amount': amount,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
    }).select('id').single();

    final transactionId = transactionResult['id'] as String;

    // Cập nhật số dư ví với giá trị đã tính toán
    await _client
        .from('wallets')
        .update({'balance': newBalance})
        .eq('id', walletId);

    // Nếu là THU NHẬP: Tự động phân bổ vào các hũ theo tỷ lệ phần trăm
    if (!isExpense) {
      await _allocateToJars(
        userId: user.id,
        transactionId: transactionId,
        incomeAmount: amount,
      );
    } else {
      // Nếu là CHI TIÊU: Tự động trừ từ hũ tương ứng với danh mục
      await _deductFromJar(
        userId: user.id,
        transactionId: transactionId,
        categoryName: categoryName,
        expenseAmount: amount,
      );
    }
  }

  /// Tự động trừ tiền từ hũ tương ứng khi chi tiêu.
  /// Mapping danh mục với hũ:
  /// - Nhu cầu thiết yếu: Chợ siêu thị, Ăn uống, Di chuyển, Sức khỏe
  /// - Giáo dục: (các danh mục liên quan giáo dục)
  /// - Hưởng thụ: Mua sắm, Giải trí, Làm đẹp
  /// - Cho đi: Từ thiện
  /// - Tiết kiệm dài hạn: (không trừ khi chi tiêu)
  /// - Tự do tài chính: (không trừ khi chi tiêu)
  static Future<void> _deductFromJar({
    required String userId,
    required String transactionId,
    required String categoryName,
    required int expenseAmount,
  }) async {
    // Lấy danh sách các hũ đang hoạt động
    final jars = await _client
        .from('jars')
        .select('id, name, slug, balance')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    if (jars.isEmpty) {
      // Nếu chưa có hũ, không trừ (hoặc có thể tạo hũ mặc định)
      return;
    }

    // Xác định hũ tương ứng với danh mục chi tiêu
    String? targetJarId;
    String? targetJarSlug;

    // Mapping danh mục với hũ dựa trên tên danh mục
    final categoryLower = categoryName.toLowerCase();
    
    if (categoryLower.contains('chợ') || 
        categoryLower.contains('siêu thị') ||
        categoryLower.contains('ăn uống') ||
        categoryLower.contains('ăn') ||
        categoryLower.contains('di chuyển') ||
        categoryLower.contains('xăng') ||
        categoryLower.contains('sức khỏe') ||
        categoryLower.contains('y tế')) {
      // Nhu cầu thiết yếu
      targetJarSlug = 'necessities';
    } else if (categoryLower.contains('giáo dục') ||
               categoryLower.contains('học') ||
               categoryLower.contains('sách')) {
      // Giáo dục
      targetJarSlug = 'education';
    } else if (categoryLower.contains('mua sắm') ||
               categoryLower.contains('giải trí') ||
               categoryLower.contains('làm đẹp') ||
               categoryLower.contains('du lịch')) {
      // Hưởng thụ
      targetJarSlug = 'play';
    } else if (categoryLower.contains('từ thiện') ||
               categoryLower.contains('cho đi') ||
               categoryLower.contains('quyên góp')) {
      // Cho đi
      targetJarSlug = 'give';
    }

    // Tìm hũ tương ứng
    if (targetJarSlug != null) {
      for (final jar in jars) {
        final slug = (jar['slug'] as String?) ?? '';
        if (slug == targetJarSlug) {
          targetJarId = jar['id'] as String;
          break;
        }
      }
    }

    // Nếu không tìm thấy hũ tương ứng, mặc định trừ từ "Nhu cầu thiết yếu"
    if (targetJarId == null) {
      for (final jar in jars) {
        final slug = (jar['slug'] as String?) ?? '';
        if (slug == 'necessities' || slug.contains('nhu cầu')) {
          targetJarId = jar['id'] as String;
          break;
        }
      }
    }

    // Nếu vẫn không tìm thấy, lấy hũ đầu tiên
    if (targetJarId == null && jars.isNotEmpty) {
      targetJarId = jars[0]['id'] as String;
    }

    if (targetJarId == null) return;

    // Lấy số dư hiện tại của hũ
    final jar = jars.firstWhere(
      (j) => j['id'] == targetJarId,
      orElse: () => jars[0],
    );
    final currentBalance = (jar['balance'] as num?) ?? 0;

    // Tính số dư mới (trừ đi số tiền chi tiêu)
    final newBalance = (currentBalance - expenseAmount).clamp(0, double.infinity);

    // Cập nhật số dư hũ
    await _client
        .from('jars')
        .update({'balance': newBalance})
        .eq('id', targetJarId);

    // Lưu vào jar_allocations để theo dõi (với số âm hoặc ghi chú là chi tiêu)
    // Note: jar_allocations thường dùng cho thu nhập, nhưng có thể dùng để track chi tiêu
    await _client.from('jar_allocations').insert({
      'jar_id': targetJarId,
      'transaction_id': transactionId,
      'amount': expenseAmount, // Lưu số dương, nhưng đã trừ từ balance
    });
  }

  /// Tự động phân bổ thu nhập vào các hũ theo tỷ lệ phần trăm đã cấu hình.
  static Future<void> _allocateToJars({
    required String userId,
    required String transactionId,
    required int incomeAmount,
  }) async {
    // Lấy danh sách các hũ đang hoạt động của user
    final jars = await _client
        .from('jars')
        .select('id, percentage, balance')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    if (jars.isEmpty) {
      // Nếu chưa có hũ, tạo 6 hũ mặc định với tỷ lệ chuẩn
      await _createDefaultJars(userId: userId);
      // Đọc lại sau khi tạo
      final newJars = await _client
          .from('jars')
          .select('id, percentage, balance')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: true);
      
      await _distributeToJars(
        jars: newJars,
        transactionId: transactionId,
        incomeAmount: incomeAmount,
      );
      return;
    }

    await _distributeToJars(
      jars: jars,
      transactionId: transactionId,
      incomeAmount: incomeAmount,
    );
  }

  /// Phân bổ tiền vào các hũ và cập nhật số dư.
  static Future<void> _distributeToJars({
    required List<dynamic> jars,
    required String transactionId,
    required int incomeAmount,
  }) async {
    final allocations = <Map<String, dynamic>>[];
    final jarUpdates = <String, num>{};

    for (final jar in jars) {
      final jarId = jar['id'] as String;
      final percentage = (jar['percentage'] as num?) ?? 0;
      final currentBalance = (jar['balance'] as num?) ?? 0;

      // Tính số tiền phân bổ cho hũ này
      final allocatedAmount = (incomeAmount * percentage / 100).round();

      if (allocatedAmount > 0) {
        // Lưu phân bổ vào jar_allocations
        allocations.add({
          'jar_id': jarId,
          'transaction_id': transactionId,
          'amount': allocatedAmount,
        });

        // Cập nhật số dư hũ
        jarUpdates[jarId] = currentBalance + allocatedAmount;
      }
    }

    // Insert tất cả jar_allocations
    if (allocations.isNotEmpty) {
      await _client.from('jar_allocations').insert(allocations);
    }

    // Cập nhật số dư cho từng hũ
    for (final entry in jarUpdates.entries) {
      await _client
          .from('jars')
          .update({'balance': entry.value})
          .eq('id', entry.key);
    }
  }

  /// Tạo 6 hũ mặc định với tỷ lệ chuẩn theo phương pháp JARS.
  static Future<void> _createDefaultJars({required String userId}) async {
    final defaultJars = [
      {'name': 'Nhu cầu thiết yếu', 'slug': 'necessities', 'percentage': 55, 'icon': 'home', 'color': '#EF4444'},
      {'name': 'Tiết kiệm dài hạn', 'slug': 'long_term_savings', 'percentage': 10, 'icon': 'savings', 'color': '#3B82F6'},
      {'name': 'Giáo dục', 'slug': 'education', 'percentage': 10, 'icon': 'school', 'color': '#F59E0B'},
      {'name': 'Hưởng thụ', 'slug': 'play', 'percentage': 10, 'icon': 'celebration', 'color': '#8B5CF6'},
      {'name': 'Tự do tài chính', 'slug': 'financial_freedom', 'percentage': 10, 'icon': 'account_balance_wallet', 'color': '#10B981'},
      {'name': 'Cho đi', 'slug': 'give', 'percentage': 5, 'icon': 'favorite', 'color': '#EC4899'},
    ];

    for (final jar in defaultJars) {
      await _client.from('jars').insert({
        'user_id': userId,
        'name': jar['name'],
        'slug': jar['slug'],
        'percentage': jar['percentage'],
        'balance': 0,
        'icon': jar['icon'],
        'color': jar['color'],
        'is_active': true,
      });
    }
  }
}


