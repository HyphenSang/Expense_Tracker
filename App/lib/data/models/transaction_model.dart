import '../../domain/entities/transaction_entity.dart';

/// Data model cho Transaction (DTO từ Supabase)
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.walletId,
    required super.categoryId,
    required super.type,
    required super.amount,
    required super.note,
    required super.occurredAt,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      walletId: json['wallet_id'] as String,
      categoryId: json['category_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num),
      note: json['note'] as String? ?? '',
      occurredAt: DateTime.parse(json['occurred_at'] as String).toLocal(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionEntity toEntity() => this;
}

