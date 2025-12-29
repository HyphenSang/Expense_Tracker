import '../../domain/entities/category.dart';
import '../../domain/repositories/category.dart' as domain;
import '../datasources/supabase.dart';
import '../models/category.dart';

/// Implementation của CategoryRepository
class CategoryRepositoryImpl implements domain.CategoryRepository {
  final SupabaseDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryEntity>> getCategories({
    required String userId,
    String? type,
  }) async {
    final categories = await _dataSource.getCategories(userId: userId, type: type);
    return categories.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<CategoryEntity> getOrCreateCategory({
    required String userId,
    required String categoryName,
    required String type,
  }) async {
    final category = await _dataSource.getOrCreateCategory(
      userId: userId,
      categoryName: categoryName,
      type: type,
    );
    return CategoryModel.fromJson(category);
  }

  @override
  Future<CategoryEntity> createCategory({
    required String userId,
    required String name,
    required String type,
    String? icon,
    String? color,
    String? jarId,
  }) async {
    final category = await _dataSource.createCategory(
      userId: userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      jarId: jarId,
    );
    return CategoryModel.fromJson(category);
  }

  @override
  Future<CategoryEntity> updateCategory({
    required String categoryId,
    String? name,
    String? type,
    String? icon,
    String? color,
    String? jarId,
  }) async {
    final category = await _dataSource.updateCategory(
      categoryId: categoryId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      jarId: jarId,
    );
    return CategoryModel.fromJson(category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _dataSource.deleteCategory(categoryId);
  }
}

