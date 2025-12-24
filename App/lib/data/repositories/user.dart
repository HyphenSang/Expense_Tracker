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

