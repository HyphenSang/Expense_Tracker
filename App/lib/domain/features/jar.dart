import '../repositories/jar.dart';
import '../entities/jar.dart';

/// Use case để lấy danh sách hũ của user
class GetJars {
  final JarRepository _repository;
  final String _userId;

  GetJars(this._repository, this._userId);

  Future<List<JarEntity>> call() async {
    return await _repository.getJars(_userId);
  }
}

/// Use case để lấy tất cả hũ của user (bao gồm cả không active)
class GetAllJars {
  final JarRepository _repository;
  final String _userId;

  GetAllJars(this._repository, this._userId);

  Future<List<JarEntity>> call() async {
    return await _repository.getAllJars(_userId);
  }
}

/// Use case để tạo hũ mới
class CreateJar {
  final JarRepository _repository;
  final String _userId;

  CreateJar(this._repository, this._userId);

  Future<JarEntity> call({
    required String name,
    required String slug,
    required int percentage,
    String? icon,
    String? color,
    String? description,
    double? targetAmount,
  }) async {
    return await _repository.createJar(
      userId: _userId,
      name: name,
      slug: slug,
      percentage: percentage,
      icon: icon,
      color: color,
      description: description,
      targetAmount: targetAmount,
    );
  }
}

/// Use case để cập nhật hũ
class UpdateJar {
  final JarRepository _repository;

  UpdateJar(this._repository);

  Future<void> call({
    required String jarId,
    String? name,
    String? slug,
    int? percentage,
    String? icon,
    String? color,
    String? description,
    double? targetAmount,
    bool? isActive,
  }) async {
    return await _repository.updateJar(
      jarId: jarId,
      name: name,
      slug: slug,
      percentage: percentage,
      icon: icon,
      color: color,
      description: description,
      targetAmount: targetAmount,
      isActive: isActive,
    );
  }
}

/// Use case để xóa hũ
class DeleteJar {
  final JarRepository _repository;

  DeleteJar(this._repository);

  Future<void> call(String jarId) async {
    return await _repository.deleteJar(jarId);
  }
}

