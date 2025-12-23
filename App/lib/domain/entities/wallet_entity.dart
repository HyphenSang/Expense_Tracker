/// Entity đại diện cho một ví trong domain layer
class WalletEntity {
  final String id;
  final String userId;
  final String name;
  final String type;
  final num balance;
  final String? bankName;
  final bool isActive;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.bankName,
    this.isActive = true,
  });
}

