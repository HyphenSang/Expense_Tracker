import '../../entities/user_profile.dart';
import '../../repositories/user.dart';

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

