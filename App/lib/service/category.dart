import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để quản lý danh mục (categories) của user.
class CategoryService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static User? get _currentUser => _client.auth.currentUser;

  /// Tạo danh mục mới cho user hiện tại.
  ///
  /// [name]: Tên danh mục (bắt buộc)
  /// [type]: Loại danh mục - 'EXPENSE' hoặc 'INCOME' (bắt buộc)
  /// [icon]: Tên icon (tùy chọn, mặc định: 'category')
  /// [color]: Màu hex (tùy chọn, mặc định: '#6B7280')
  static Future<String> createCategory({
    required String name,
    required String type, // 'EXPENSE' hoặc 'INCOME'
    String? icon,
    String? color,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tạo danh mục.');
    }

    // Kiểm tra danh mục đã tồn tại chưa
    final existing = await _client
        .from('categories')
        .select('id')
        .eq('user_id', user.id)
        .eq('name', name)
        .eq('type', type)
        .maybeSingle();

    if (existing != null) {
      throw StateError('Danh mục "$name" đã tồn tại cho loại ${type == 'EXPENSE' ? 'chi tiêu' : 'thu nhập'}.');
    }

    // Tạo danh mục mới
    final result = await _client
        .from('categories')
        .insert({
          'user_id': user.id,
          'name': name,
          'type': type,
          'icon': icon ?? 'category',
          'color': color ?? '#6B7280',
          'is_system': false,
        })
        .select('id')
        .single();

    return result['id'] as String;
  }

  /// Lấy danh sách danh mục của user hiện tại theo loại.
  static Future<List<Map<String, dynamic>>> getCategories({
    String? type, // 'EXPENSE' hoặc 'INCOME', null = tất cả
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa đăng nhập – không thể tải danh mục.');
    }

    var query = _client
        .from('categories')
        .select('id, name, type, icon, color')
        .eq('user_id', user.id);

    if (type != null) {
      query = query.eq('type', type);
    }

    final result = await query.order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(result);
  }
}

