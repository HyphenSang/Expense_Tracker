import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để quản lý ví và tài khoản ngân hàng.
class WalletService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static User? get _currentUser => _client.auth.currentUser;

  /// Tạo ví hoặc tài khoản ngân hàng mới.
  ///
  /// [name]: Tên ví/tài khoản (bắt buộc)
  /// [type]: Loại - 'CASH', 'BANK', 'CARD', 'EWALLET' (bắt buộc)
  /// [bankName]: Tên ngân hàng (bắt buộc nếu type là 'BANK')
  /// [accountNumber]: Số tài khoản (tùy chọn)
  /// [initialBalance]: Số dư ban đầu (mặc định: 0)
  static Future<String> createWallet({
    required String name,
    required String type,
    String? bankName,
    String? accountNumber,
    num initialBalance = 0,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tạo ví.');
    }

    // Validate
    if (name.trim().isEmpty) {
      throw StateError('Tên ví không được để trống.');
    }

    if (type == 'BANK' && (bankName == null || bankName.trim().isEmpty)) {
      throw StateError('Vui lòng chọn ngân hàng.');
    }

    // Tạo ví mới
    final result = await _client
        .from('wallets')
        .insert({
          'user_id': user.id,
          'name': name.trim(),
          'type': type,
          'bank_name': bankName?.trim(),
          'account_number': accountNumber?.trim(),
          'balance': initialBalance,
          'is_active': true,
        })
        .select('id')
        .single();

    return result['id'] as String;
  }

  /// Lấy danh sách ví của user hiện tại.
  static Future<List<Map<String, dynamic>>> getWallets() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải danh sách ví.');
    }

    final result = await _client
        .from('wallets')
        .select('id, name, type, bank_name, account_number, balance, is_active')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    return result;
  }
}


