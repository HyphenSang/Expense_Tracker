import '../entities/wallet_entity.dart';

/// Repository interface cho Wallet trong domain layer
abstract class WalletRepository {
  /// Lấy danh sách ví của user
  Future<List<WalletEntity>> getWallets(String userId);

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

  /// Xóa ví
  Future<void> deleteWallet(String walletId);
}

