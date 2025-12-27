/// Entity đại diện cho một ngân sách trong domain layer
class BudgetEntity {
  final String id;
  final String userId;
  final String? categoryId;
  final String? jarId;
  final String period; // 'MONTHLY', 'WEEKLY', 'YEARLY'
  final num limitAmount;
  final num spentAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.userId,
    this.categoryId,
    this.jarId,
    required this.period,
    required this.limitAmount,
    required this.spentAmount,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });
}

