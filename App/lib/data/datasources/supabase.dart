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

  Future<Map<String, dynamic>> createCategory(
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('categories')
        .insert(data)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
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
    final result = await _client
        .from('profiles')
        .update(data)
        .eq('id', userId)
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
}

