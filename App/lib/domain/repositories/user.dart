import '../entities/user_profile.dart';

/// Repository interface cho User trong domain layer
abstract class UserRepository {
  /// Lấy profile của user
  Future<UserProfileEntity> getUserProfile(String userId);

  /// Cập nhật profile của user
  Future<UserProfileEntity> updateUserProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
  });
}

