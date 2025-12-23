import '../../domain/entities/wallet_entity.dart';

/// Data model cho Wallet (DTO từ Supabase)
class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    super.bankName,
    super.isActive,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num),
      bankName: json['bank_name'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'bank_name': bankName,
      'is_active': isActive,
    };
  }

  WalletEntity toEntity() => this;
}

