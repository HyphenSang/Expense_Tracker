import '../repositories/user.dart';
import '../entities/user_profile.dart';

/// Use case để lấy profile của user hiện tại
class GetCurrentUserProfile {
  final UserRepository _repository;

  GetCurrentUserProfile(this._repository);

  Future<UserProfileEntity?> call() async {
    return await _repository.getCurrentUserProfile();
  }
}

/// Use case để đảm bảo user hiện tại có profile, tạo mới nếu chưa tồn tại
class EnsureCurrentUserProfile {
  final UserRepository _repository;

  EnsureCurrentUserProfile(this._repository);

  Future<UserProfileEntity> call({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _repository.ensureCurrentUserProfile(
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}

/// Use case để cập nhật profile của user
class UpdateUserProfile {
  final UserRepository _repository;

  UpdateUserProfile(this._repository);

  Future<UserProfileEntity> call({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await _repository.updateUserProfile(
      userId: userId,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}

