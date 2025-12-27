import '../repositories/wallet.dart';
import '../entities/wallet.dart';

/// Use case để tạo ví mới
class CreateWallet {
  final WalletRepository _repository;
  final String _userId;

  CreateWallet(this._repository, this._userId);

  Future<WalletEntity> call({
    required String name,
    required String type,
    required num balance,
    String? bankName,
  }) async {
    return await _repository.createWallet(
      userId: _userId,
      name: name,
      type: type,
      balance: balance,
      bankName: bankName,
    );
  }
}

/// Use case để lấy ví đầu tiên của user hoặc tạo ví mặc định
class GetOrCreateDefaultWallet {
  final WalletRepository _repository;
  final String _userId;

  GetOrCreateDefaultWallet(this._repository, this._userId);

  Future<WalletEntity> call() async {
    return await _repository.getOrCreateDefaultWallet(_userId);
  }
}

/// Use case để lấy tất cả ví của user (bao gồm cả không hoạt động)
class GetAllWallets {
  final WalletRepository _repository;
  final String _userId;

  GetAllWallets(this._repository, this._userId);

  Future<List<WalletEntity>> call() async {
    return await _repository.getAllWallets(_userId);
  }
}

/// Use case để cập nhật trạng thái hoạt động của ví
class UpdateWalletStatus {
  final WalletRepository _repository;

  UpdateWalletStatus(this._repository);

  Future<void> call({
    required String walletId,
    required bool isActive,
  }) async {
    await _repository.updateWallet(
      walletId: walletId,
      isActive: isActive,
    );
  }
}

