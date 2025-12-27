import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth.dart' as domain;
import '../datasources/supabase.dart';
import '../models/user_profile.dart';

/// Implementation của AuthRepository
class AuthRepositoryImpl implements domain.AuthRepository {
  final SupabaseDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserProfileEntity> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _dataSource.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Đăng ký thất bại');
    }

    // Tạo profile nếu chưa có
    final profile = await _dataSource.getUserProfile(response.user!.id);
    if (profile == null && username != null) {
      await _dataSource.updateUserProfile(response.user!.id, {
        'username': username,
      });
    }

    return UserProfileModel(
      id: response.user!.id,
      username: username,
    ).toEntity();
  }

  @override
  Future<UserProfileEntity> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.signIn(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Đăng nhập thất bại');
    }

    final profile = await _dataSource.getUserProfile(response.user!.id);
    if (profile != null) {
      return UserProfileModel.fromJson(profile).toEntity();
    }

    return UserProfileModel(id: response.user!.id).toEntity();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  UserProfileEntity? getCurrentUser() {
    final user = _dataSource.getCurrentAuthUser();
    if (user == null) return null;
    return UserProfileModel(id: user.id).toEntity();
  }

  @override
  bool isLoggedIn() {
    return _dataSource.getCurrentAuthUser() != null;
  }

  @override
  Stream<UserProfileEntity?> authStateChanges() {
    return _dataSource.authStateChanges().map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return UserProfileModel(id: user.id).toEntity();
    });
  }

  @override
  Future<void> reAuthenticate(String password) async {
    await _dataSource.reAuthenticate(password);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _dataSource.updatePassword(newPassword);
  }
}

