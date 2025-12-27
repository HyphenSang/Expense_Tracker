import '../entities/wallet.dart';

/// Repository interface cho Wallet trong domain layer
abstract class WalletRepository {
  /// Lấy danh sách ví của user (chỉ ví đang hoạt động)
  Future<List<WalletEntity>> getWallets(String userId);

  /// Lấy tất cả ví của user (bao gồm cả không hoạt động)
  Future<List<WalletEntity>> getAllWallets(String userId);

  /// Lấy ví theo ID
  Future<WalletEntity?> getWalletById(String walletId);

  /// Tạo ví mới
  Future<WalletEntity> createWallet({
    required String userId,
    required String name,
    required String type,
    required num balance,
    String? bankName,
  });

  /// Cập nhật số dư ví
  Future<void> updateWalletBalance({
    required String walletId,
    required num balance,
  });

  /// Cập nhật thông tin ví (bao gồm is_active)
  Future<void> updateWallet({
    required String walletId,
    bool? isActive,
  });

  /// Lấy ví đầu tiên của user hoặc tạo ví mặc định
  Future<WalletEntity> getOrCreateDefaultWallet(String userId);

  /// Xóa ví
  Future<void> deleteWallet(String walletId);
}

