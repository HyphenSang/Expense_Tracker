import '../entities/category.dart';

/// Repository interface cho Category trong domain layer
abstract class CategoryRepository {
  /// Lấy danh sách danh mục của user
  Future<List<CategoryEntity>> getCategories({
    required String userId,
    String? type, // 'INCOME' hoặc 'EXPENSE'
  });

  /// Lấy hoặc tạo category từ tên
  Future<CategoryEntity> getOrCreateCategory({
    required String userId,
    required String categoryName,
    required String type,
  });

  /// Tạo category mới
  Future<CategoryEntity> createCategory({
    required String userId,
    required String name,
    required String type,
    String? icon,
    String? color,
  });

  /// Xóa category
  Future<void> deleteCategory(String categoryId);
}

