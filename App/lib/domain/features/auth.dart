import '../repositories/auth.dart';
import '../entities/user_profile.dart';

/// Use case để đăng nhập
class SignIn {
  final AuthRepository _repository;

  SignIn(this._repository);

  Future<UserProfileEntity> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signIn(
      email: email,
      password: password,
    );
  }
}

/// Use case để đăng ký
class SignUp {
  final AuthRepository _repository;

  SignUp(this._repository);

  Future<UserProfileEntity> call({
    required String email,
    required String password,
    String? username,
  }) async {
    return await _repository.signUp(
      email: email,
      password: password,
      username: username,
    );
  }
}

/// Use case để đăng xuất
class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<void> call() async {
    await _repository.signOut();
  }
}

/// Use case để lấy user hiện tại
class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  UserProfileEntity? call() {
    return _repository.getCurrentUser();
  }
}

/// Use case để cập nhật mật khẩu
class UpdatePassword {
  final AuthRepository _repository;

  UpdatePassword(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }

    try {
      await _repository.reAuthenticate(currentPassword);
    } catch (e) {
      if (e.toString().contains('Invalid login credentials') ||
          e.toString().contains('invalid_credentials')) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }
      rethrow;
    }

    await _repository.updatePassword(newPassword);
  }
}

