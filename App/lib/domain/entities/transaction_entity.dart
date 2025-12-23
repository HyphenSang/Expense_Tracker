/// Entity đại diện cho một giao dịch trong domain layer
class TransactionEntity {
  final String id;
  final String userId;
  final String walletId;
  final String categoryId;
  final String type; // 'INCOME' hoặc 'EXPENSE'
  final num amount;
  final String note;
  final DateTime occurredAt;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.note,
    required this.occurredAt,
    required this.createdAt,
  });
}

