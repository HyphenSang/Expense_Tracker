import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet.dart' as domain;
import '../datasources/supabase.dart';
import '../models/wallet.dart';

/// Implementation của WalletRepository
class WalletRepositoryImpl implements domain.WalletRepository {
  final SupabaseDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  @override
  Future<List<WalletEntity>> getWallets(String userId) async {
    final data = await _dataSource.getWallets(userId);
    return data.map((json) => WalletModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<WalletEntity?> getWalletById(String walletId) async {
    // TODO: Implement getWalletById trong SupabaseDataSource
    // Tạm thời trả về null, cần thêm method trong datasource
    return null;
  }

  @override
  Future<WalletEntity> createWallet({
    required String userId,
    required String name,
    required String type,
    required num balance,
    String? bankName,
  }) async {
    final data = {
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'bank_name': bankName,
      'is_active': true,
    };

    final result = await _dataSource.createWallet(data);
    return WalletModel.fromJson(result).toEntity();
  }

  @override
  Future<void> updateWalletBalance({
    required String walletId,
    required num balance,
  }) async {
    await _dataSource.updateWallet(walletId, {'balance': balance});
  }

  @override
  Future<WalletEntity> getOrCreateDefaultWallet(String userId) async {
    final result = await _dataSource.getOrCreateDefaultWallet(userId);
    return WalletModel.fromJson(result).toEntity();
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await _dataSource.deleteWallet(walletId);
  }
}

