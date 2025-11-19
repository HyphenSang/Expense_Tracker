import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model đại diện cho bản ghi trong bảng `profiles`.
class UserProfile {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      username: data['username'] as String?,
      fullName: data['full_name'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}

/// Model đại diện cho bản ghi trong bảng `roles`.
class UserRole {
  final String id;
  final String name;

  const UserRole({required this.id, required this.name});

  factory UserRole.fromMap(Map<String, dynamic> data) {
    return UserRole(id: data['id'] as String, name: data['name'] as String);
  }
}

/// Service thao tác dữ liệu người dùng với Supabase.
class UserService {
  static const _profilesTable = 'profiles';
  static const _adminsTable = 'admins';
  static const _rolesTable = 'roles';

  static SupabaseClient get _client => SupabaseConfig.client;
  static User? get _currentUser => _client.auth.currentUser;

  /// Lấy profile theo `userId`.
  static Future<UserProfile?> getProfileById(String userId) async {
    if (userId.isEmpty) return null;

    final response = await _client
        .from(_profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromMap(response);
  }

  /// Lấy profile của user hiện tại (nếu đã đăng nhập).
  static Future<UserProfile?> getCurrentUserProfile() async {
    final user = _currentUser;
    if (user == null) return null;
    return getProfileById(user.id);
  }

  /// Tạo mới hoặc cập nhật profile (dựa trên khóa chính `id`).
  static Future<UserProfile> upsertProfile(UserProfile profile) async {
    final response = await _client
        .from(_profilesTable)
        .upsert(profile.toMap(), onConflict: 'id')
        .select()
        .single();

    return UserProfile.fromMap(response);
  }

  /// Đảm bảo user hiện tại có profile, tạo mới nếu chưa tồn tại.
  static Future<UserProfile> ensureCurrentUserProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa có người dùng đăng nhập để tạo profile.');
    }

    final fallbackUsername =
        username ??
        user.userMetadata?['username'] as String? ??
        user.email?.split('@').first ??
        'User';

    final existingProfile = await getProfileById(user.id);

    return upsertProfile(
      UserProfile(
        id: user.id,
        username: fallbackUsername,
        fullName: fullName ?? existingProfile?.fullName,
        avatarUrl: avatarUrl ?? existingProfile?.avatarUrl,
      ),
    );
  }

  /// Cập nhật profile của user hiện tại.
  static Future<UserProfile> updateCurrentUserProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('Chưa có người dùng đăng nhập để cập nhật profile.');
    }

    final payload = UserProfile(
      id: user.id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );

    return upsertProfile(payload);
  }

  /// Kiểm tra user hiện tại có nằm trong bảng `admins` hay không.
  static Future<bool> isCurrentUserAdmin() async {
    final user = _currentUser;
    if (user == null) return false;

    final response = await _client
        .from(_adminsTable)
        .select('role_id')
        .eq('user_id', user.id)
        .maybeSingle();

    return response != null;
  }

  /// Lấy role của user hiện tại (nếu nằm trong bảng `admins`).
  static Future<UserRole?> getCurrentUserRole() async {
    final user = _currentUser;
    if (user == null) return null;

    final adminRow = await _client
        .from(_adminsTable)
        .select('role_id')
        .eq('user_id', user.id)
        .maybeSingle();

    final roleId = adminRow?['role_id'] as String?;
    if (roleId == null) return null;

    final roleRow = await _client
        .from(_rolesTable)
        .select()
        .eq('id', roleId)
        .maybeSingle();

    if (roleRow == null) return null;
    return UserRole.fromMap(roleRow);
  }
}
