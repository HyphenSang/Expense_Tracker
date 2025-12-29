import '../repositories/category.dart';
import '../entities/category.dart';

/// Use case để lấy danh sách danh mục
class GetCategories {
  final CategoryRepository _repository;
  final String _userId;

  GetCategories(this._repository, this._userId);

  Future<List<CategoryEntity>> call({String? type}) async {
    return await _repository.getCategories(
      userId: _userId,
      type: type,
    );
  }
}

/// Use case để tạo danh mục mới
class CreateCategory {
  final CategoryRepository _repository;
  final String _userId;

  CreateCategory(this._repository, this._userId);

  Future<CategoryEntity> call({
    required String name,
    required String type,
    String? icon,
    String? color,
    String? categoryGroup,
    String? jarId,
  }) async {
    return await _repository.createCategory(
      userId: _userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      categoryGroup: categoryGroup,
      jarId: jarId,
    );
  }
}

/// Use case để lấy hoặc tạo category từ tên
class GetOrCreateCategory {
  final CategoryRepository _repository;
  final String _userId;

  GetOrCreateCategory(this._repository, this._userId);

  Future<CategoryEntity> call({
    required String categoryName,
    required String type,
  }) async {
    return await _repository.getOrCreateCategory(
      userId: _userId,
      categoryName: categoryName,
      type: type,
    );
  }
}

/// Use case để cập nhật category
class UpdateCategory {
  final CategoryRepository _repository;

  UpdateCategory(this._repository);

  Future<CategoryEntity> call({
    required String categoryId,
    String? name,
    String? type,
    String? icon,
    String? color,
    String? categoryGroup,
    String? jarId,
  }) async {
    return await _repository.updateCategory(
      categoryId: categoryId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      categoryGroup: categoryGroup,
      jarId: jarId,
    );
  }
}

/// Use case để xóa category
class DeleteCategory {
  final CategoryRepository _repository;

  DeleteCategory(this._repository);

  Future<void> call(String categoryId) async {
    return await _repository.deleteCategory(categoryId);
  }
}

