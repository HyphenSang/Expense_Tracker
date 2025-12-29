import '../../domain/entities/category.dart';

/// Data model cho Category (DTO từ Supabase)
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    super.isSystem,
    super.jarId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isSystem: (json['is_system'] as bool?) ?? false,
      jarId: json['jar_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_system': isSystem,
      'jar_id': jarId,
    };
  }

  CategoryEntity toEntity() => this;
}

