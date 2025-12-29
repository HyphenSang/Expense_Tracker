import '../entities/jar.dart';

/// Repository interface cho Jar trong domain layer
abstract class JarRepository {
  /// Lấy danh sách hũ của user
  Future<List<JarEntity>> getJars(String userId);

  /// Lấy tất cả hũ của user (bao gồm cả không active)
  Future<List<JarEntity>> getAllJars(String userId);

  /// Đảm bảo 6 hũ mặc định được tạo cho user
  Future<void> ensureDefaultJars(String userId);

  /// Tạo hũ mới
  Future<JarEntity> createJar({
    required String userId,
    required String name,
    required String slug,
    required int percentage,
    String? icon,
    String? color,
    String? description,
    double? targetAmount,
  });

  /// Cập nhật hũ
  Future<void> updateJar({
    required String jarId,
    String? name,
    String? slug,
    int? percentage,
    String? icon,
    String? color,
    String? description,
    double? targetAmount,
    bool? isActive,
  });

  /// Xóa hũ (set is_active = false)
  Future<void> deleteJar(String jarId);

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

  /// Chia lại các hũ theo % dựa trên total balance của wallets
  Future<void> redistributeJarsByTotalBalance(String userId);
}

