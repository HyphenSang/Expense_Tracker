import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user.dart' as domain;
import '../datasources/supabase.dart';
import '../models/user_profile.dart';

/// Implementation của UserRepository
class UserRepositoryImpl implements domain.UserRepository {
  final SupabaseDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    final profile = await _dataSource.getUserProfile(userId);
    if (profile == null) {
      // Nếu chưa có profile, tạo mới với id
      final newProfile = await _dataSource.updateUserProfile(userId, {});
      return UserProfileModel.fromJson(newProfile);
    }
    return UserProfileModel.fromJson(profile);
  }

  @override
  Future<UserProfileEntity?> getCurrentUserProfile() async {
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) return null;
    final profile = await _dataSource.getUserProfile(user.id);
    if (profile == null) return null;
    final model = UserProfileModel.fromJson(profile);
    // Thêm email và userMetadata từ auth user
    return UserProfileModel(
      id: model.id,
      username: model.username,
      fullName: model.fullName,
      avatarUrl: model.avatarUrl,
      email: user.email,
      userMetadata: user.userMetadata,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<UserProfileEntity> ensureCurrentUserProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) {
      throw StateError('Chưa có người dùng đăng nhập để tạo profile.');
    }

    // Lấy profile hiện tại nếu có
    final existingProfile = await _dataSource.getUserProfile(user.id);
    
    // Tạo fallback username
    final fallbackUsername = username ??
        user.userMetadata?['username'] as String? ??
        user.email?.split('@').first ??
        'User';

    // Tạo hoặc cập nhật profile
    final updateData = <String, dynamic>{
      'username': fallbackUsername,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (existingProfile != null && fullName == null) 'full_name': existingProfile['full_name'],
      if (existingProfile != null && avatarUrl == null) 'avatar_url': existingProfile['avatar_url'],
    };

    final result = await _dataSource.updateUserProfile(user.id, updateData);
    final model = UserProfileModel.fromJson(result);
    // Thêm email và userMetadata từ auth user
    return UserProfileModel(
      id: model.id,
      username: model.username,
      fullName: model.fullName,
      avatarUrl: model.avatarUrl,
      email: user.email,
      userMetadata: user.userMetadata,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  @override
  Future<UserProfileEntity> updateUserProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (username != null) updateData['username'] = username;
    if (fullName != null) updateData['full_name'] = fullName;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    if (updateData.isEmpty) {
      // Nếu không có gì để cập nhật, trả về profile hiện tại
      return await getUserProfile(userId);
    }

    final updated = await _dataSource.updateUserProfile(userId, updateData);
    return UserProfileModel.fromJson(updated);
  }
}

