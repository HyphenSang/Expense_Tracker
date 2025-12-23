/// Entity đại diện cho profile người dùng trong domain layer
class UserProfileEntity {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });
}

