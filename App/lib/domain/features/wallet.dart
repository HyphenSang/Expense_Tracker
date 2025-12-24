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

