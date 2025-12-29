import '../../domain/entities/jar.dart';

/// Data model cho Jar (DTO từ Supabase)
class JarModel extends JarEntity {
  const JarModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.slug,
    required super.percentage,
    required super.isActive,
    super.balance,
    super.icon,
    super.color,
    super.description,
    super.targetAmount,
  });

  factory JarModel.fromJson(Map<String, dynamic> json) {
    return JarModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Jar',
      slug: json['slug'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'slug': slug,
      'percentage': percentage.round(),
      'is_active': isActive,
      'balance': balance.round(),
      'icon': icon,
      'color': color,
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'user_id': userId,
      'name': name,
      'slug': slug,
      'percentage': percentage.round(),
      'is_active': isActive,
      'balance': balance.round(),
      'icon': icon,
      'color': color,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'name': name,
      'slug': slug,
      'percentage': percentage.round(),
      'is_active': isActive,
      'balance': balance.round(),
      'icon': icon,
      'color': color,
    };
  }

  JarEntity toEntity() => this;
}

