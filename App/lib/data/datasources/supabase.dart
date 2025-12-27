import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_flutter.dart';

/// Data source để tương tác trực tiếp với Supabase
class SupabaseDataSource {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Transaction operations
  Future<List<Map<String, dynamic>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var query = _client
        .from('transactions')
        .select('*')
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('occurred_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lt('occurred_at', endDate.toIso8601String());
    }

    final orderedQuery = query.order('occurred_at', ascending: false);
    final limitedQuery = limit != null 
        ? orderedQuery.limit(limit)
        : orderedQuery;

    final result = await limitedQuery;
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('transactions')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>?> getTransactionById(String transactionId) async {
    final result = await _client
        .from('transactions')
        .select('*')
        .eq('id', transactionId)
        .maybeSingle();
    return result != null ? Map<String, dynamic>.from(result) : null;
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('transactions').delete().eq('id', transactionId);
  }

  // Wallet operations
  Future<List<Map<String, dynamic>>> getWallets(String userId) async {
    final result = await _client
        .from('wallets')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getAllWallets(String userId) async {
    final result = await _client
        .from('wallets')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>> createWallet(
    Map<String, dynamic> data,
  ) async {
    final result = await _client.from('wallets').insert(data).select().single();
    return Map<String, dynamic>.from(result);
  }

  Future<void> updateWallet(String walletId, Map<String, dynamic> data) async {
    await _client.from('wallets').update(data).eq('id', walletId);
  }

  Future<void> deleteWallet(String walletId) async {
    await _client.from('wallets').delete().eq('id', walletId);
  }

  Future<Map<String, dynamic>> getOrCreateDefaultWallet(String userId) async {
    // Tìm ví đầu tiên đang hoạt động
    final existing = await _client
        .from('wallets')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return Map<String, dynamic>.from(existing);
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
        .select()
        .single();

    return Map<String, dynamic>.from(newWallet);
  }

  // Jar operations
  Future<List<Map<String, dynamic>>> getJars(String userId) async {
    final result = await _client
        .from('jars')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getAllJars(String userId) async {
    final result = await _client
        .from('jars')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> createJars(List<Map<String, dynamic>> jars) async {
    await _client.from('jars').insert(jars);
  }

  Future<void> updateJar(String jarId, Map<String, dynamic> data) async {
    await _client.from('jars').update(data).eq('id', jarId);
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getCategories({
    required String userId,
    String? type,
  }) async {
    var query = _client
        .from('categories')
        .select('*')
        .eq('user_id', userId);

    if (type != null) {
      query = query.eq('type', type);
    }

    final result = await query;
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>?> findCategory({
    required String userId,
    required String name,
    required String type,
  }) async {
    final result = await _client
        .from('categories')
        .select('*')
        .eq('user_id', userId)
        .eq('name', name)
        .eq('type', type)
        .maybeSingle();
    return result != null ? Map<String, dynamic>.from(result) : null;
  }

  Future<Map<String, dynamic>> createCategory({
    required String userId,
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    // Kiểm tra danh mục đã tồn tại chưa
    final existing = await findCategory(
      userId: userId,
      name: name,
      type: type,
    );

    if (existing != null) {
      throw StateError('Danh mục "$name" đã tồn tại cho loại ${type == 'EXPENSE' ? 'chi tiêu' : 'thu nhập'}.');
    }

    final result = await _client
        .from('categories')
        .insert({
          'user_id': userId,
          'name': name,
          'type': type,
          'icon': icon ?? 'category',
          'color': color ?? '#6B7280',
          'is_system': false,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> getOrCreateCategory({
    required String userId,
    required String categoryName,
    required String type,
  }) async {
    // Tìm category hiện có
    final existing = await findCategory(
      userId: userId,
      name: categoryName,
      type: type,
    );

    if (existing != null) {
      return existing;
    }

    // Tạo mới nếu chưa có
    return await createCategory(
      userId: userId,
      name: categoryName,
      type: type,
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }

  // User operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final result = await _client
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
    return result != null ? Map<String, dynamic>.from(result) : null;
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    // Sử dụng upsert để tạo mới nếu chưa có, cập nhật nếu đã có
    final result = await _client
        .from('profiles')
        .upsert({
          'id': userId,
          ...data,
        }, onConflict: 'id')
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  // Auth operations
  User? getCurrentAuthUser() {
    return _client.auth.currentUser;
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  Future<void> reAuthenticate(String password) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    final email = user.email;
    if (email == null) {
      throw Exception('Email không tồn tại');
    }
    
    // Xác thực lại bằng cách sign in với mật khẩu hiện tại
    // Điều này đảm bảo user nhập đúng mật khẩu hiện tại trước khi đổi
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Kiểm tra nếu có lỗi
      if (response.user == null) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }
    } catch (e) {
      // Nếu là lỗi từ Supabase về invalid credentials
      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('invalid_credentials')) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    // Cập nhật mật khẩu mới
    // Supabase sẽ tự động cập nhật mật khẩu cho user hiện tại
    final response = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    
    // Kiểm tra nếu có lỗi
    if (response.user == null) {
      throw Exception('Không thể cập nhật mật khẩu');
    }
  }

  // Budget operations
  Future<List<Map<String, dynamic>>> getBudgets(String userId) async {
    final result = await _client
        .from('budgets')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<Map<String, dynamic>> createBudget(
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('budgets')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  Future<List<Map<String, dynamic>>> getBudgetsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    final result = await _client
        .from('budgets')
        .select('*')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getBudgetsByJar({
    required String userId,
    required String jarId,
  }) async {
    final result = await _client
        .from('budgets')
        .select('*')
        .eq('user_id', userId)
        .eq('jar_id', jarId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getJarAllocationsByTransaction({
    required String transactionId,
  }) async {
    final result = await _client
        .from('jar_allocations')
        .select('jar_id')
        .eq('transaction_id', transactionId);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getJarAllocationsByDateRange({
    required String jarId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Lấy tất cả jar_allocations của jar này với join transactions
    final allocations = await _client
        .from('jar_allocations')
        .select('amount, transaction_id, transactions!inner(id, occurred_at)')
        .eq('jar_id', jarId);

    // Filter trong Dart theo date range
    final filtered = (allocations as List).where((a) {
      final transaction = a['transactions'] as Map<String, dynamic>?;
      if (transaction == null) return false;
      final occurredAtStr = transaction['occurred_at'] as String?;
      if (occurredAtStr == null) return false;
      final occurredAt = DateTime.parse(occurredAtStr);
      return occurredAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          occurredAt.isBefore(endDate);
    }).toList();

    return List<Map<String, dynamic>>.from(filtered);
  }

  Future<void> updateBudget({
    required String budgetId,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('budgets')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', budgetId);
  }

  Future<void> deleteBudget(String budgetId) async {
    await _client
        .from('budgets')
        .delete()
        .eq('id', budgetId);
  }
}

