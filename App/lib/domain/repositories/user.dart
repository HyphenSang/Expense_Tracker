import '../entities/user_profile.dart';

/// Repository interface cho User trong domain layer
abstract class UserRepository {
  /// Lấy profile của user
  Future<UserProfileEntity> getUserProfile(String userId);

  /// Lấy profile của user hiện tại
  Future<UserProfileEntity?> getCurrentUserProfile();

  /// Đảm bảo user hiện tại có profile, tạo mới nếu chưa tồn tại
  Future<UserProfileEntity> ensureCurrentUserProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  });

  /// Cập nhật profile của user
  Future<UserProfileEntity> updateUserProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
  });
}

