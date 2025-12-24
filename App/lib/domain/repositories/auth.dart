import '../entities/user_profile.dart';

/// Repository interface cho Authentication trong domain layer
abstract class AuthRepository {
  /// Đăng ký user mới
  Future<UserProfileEntity> signUp({
    required String email,
    required String password,
    String? username,
  });

  /// Đăng nhập
  Future<UserProfileEntity> signIn({
    required String email,
    required String password,
  });

  /// Đăng xuất
  Future<void> signOut();

  /// Lấy user hiện tại
  UserProfileEntity? getCurrentUser();

  /// Kiểm tra đã đăng nhập chưa
  bool isLoggedIn();

  /// Lắng nghe thay đổi trạng thái auth
  Stream<UserProfileEntity?> authStateChanges();

  /// Xác thực lại với mật khẩu hiện tại
  Future<void> reAuthenticate(String password);

  /// Cập nhật mật khẩu
  Future<void> updatePassword(String newPassword);
}

