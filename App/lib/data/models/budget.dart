import '../../domain/entities/budget.dart';

/// Model (DTO) cho Budget, extends BudgetEntity
class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    super.categoryId,
    super.jarId,
    required super.period,
    required super.limitAmount,
    required super.spentAmount,
    required super.startDate,
    super.endDate,
    required super.isActive,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      jarId: json['jar_id'] as String?,
      period: json['period'] as String,
      limitAmount: json['limit_amount'] as num,
      spentAmount: json['spent_amount'] as num,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'jar_id': jarId,
      'period': period,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  BudgetEntity toEntity() => this;
}

