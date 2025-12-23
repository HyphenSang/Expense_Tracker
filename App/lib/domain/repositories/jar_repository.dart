import '../entities/jar_entity.dart';

/// Repository interface cho Jar trong domain layer
abstract class JarRepository {
  /// Lấy danh sách hũ của user
  Future<List<JarEntity>> getJars(String userId);

  /// Đảm bảo 6 hũ mặc định được tạo cho user
  Future<void> ensureDefaultJars(String userId);

  /// Cập nhật phần trăm của các hũ
  Future<void> updateJarPercentages({
    required String userId,
    required Map<String, double> jarPercentages,
  });

  /// Cập nhật số dư của hũ
  Future<void> updateJarBalance({
    required String jarId,
    required double balance,
  });
}

