/// Entity đại diện cho một hũ tài chính trong domain layer
class JarEntity {
  final String id;
  final String userId;
  final String name;
  final String slug;
  final double percentage;
  final bool isActive;
  final double balance;
  final String? icon;
  final String? color;

  const JarEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.percentage,
    required this.isActive,
    this.balance = 0,
    this.icon,
    this.color,
  });
}

