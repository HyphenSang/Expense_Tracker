/// Entity đại diện cho một danh mục trong domain layer
class CategoryEntity {
  final String id;
  final String userId;
  final String name;
  final String type; // 'INCOME' hoặc 'EXPENSE'
  final String? icon;
  final String? color;
  final bool isSystem;
  final String? jarId; // Liên kết với jar (bắt buộc cho EXPENSE)

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isSystem = false,
    this.jarId,
  });
}

