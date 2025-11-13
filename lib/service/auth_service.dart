import 'dart:async';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để quản lý authentication với Supabase
class AuthService {
  /// Lấy Supabase client
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Lấy user hiện tại
  static User? get currentUser => _client.auth.currentUser;

  /// Kiểm tra user đã đăng nhập chưa
  static bool get isLoggedIn => currentUser != null;

  /// Đăng ký người dùng mới
  /// 
  /// [email]: Email của người dùng
  /// [password]: Mật khẩu
  /// [username]: Tên người dùng (optional)
  /// 
  /// Trả về [AuthResponse] nếu thành công, throw exception nếu thất bại
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập với email và password
  /// 
  /// [email]: Email của người dùng
  /// [password]: Mật khẩu
  /// 
  /// Trả về [AuthResponse] nếu thành công, throw exception nếu thất bại
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  /// 
  /// Trả về void nếu thành công, throw exception nếu thất bại
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thông tin user hiện tại
  /// 
  /// Trả về [User] nếu đã đăng nhập, null nếu chưa đăng nhập
  static User? getUser() {
    return currentUser;
  }

  /// Lắng nghe thay đổi trạng thái authentication
  /// 
  /// [callback]: Hàm được gọi khi có thay đổi
  /// Trả về [StreamSubscription] để có thể hủy subscription
  static StreamSubscription<AuthState>? onAuthStateChange(
    void Function(AuthState state) callback,
  ) {
    return _client.auth.onAuthStateChange.listen((data) {
      callback(data);
    });
  }

  /// Đặt lại mật khẩu
  /// 
  /// [email]: Email của người dùng
  /// 
  /// Trả về void nếu thành công, throw exception nếu thất bại
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật mật khẩu
  /// 
  /// [newPassword]: Mật khẩu mới
  /// 
  /// Trả về void nếu thành công, throw exception nếu thất bại
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật thông tin user
  /// 
  /// [data]: Map chứa thông tin cần cập nhật
  /// 
  /// Trả về [UserResponse] nếu thành công, throw exception nếu thất bại
  static Future<UserResponse> updateUser(Map<String, dynamic> data) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

