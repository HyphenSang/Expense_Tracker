import '../../domain/entities/jar_entity.dart';
import '../../domain/repositories/jar_repository.dart';
import '../datasources/supabase_datasource.dart';
import '../models/jar_model.dart';

/// Implementation của JarRepository
class JarRepositoryImpl implements JarRepository {
  final SupabaseDataSource _dataSource;

  JarRepositoryImpl(this._dataSource);

  @override
  Future<List<JarEntity>> getJars(String userId) async {
    final data = await _dataSource.getJars(userId);
    return data.map((json) => JarModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<void> ensureDefaultJars(String userId) async {
    final existing = await _dataSource.getJars(userId);
    if (existing.isNotEmpty) return;

    final defaultJars = [
      {
        'user_id': userId,
        'name': 'Nhu cầu thiết yếu',
        'slug': 'necessities',
        'percentage': 55,
        'icon': 'home',
        'color': '#EF4444',
        'is_active': true,
        'balance': 0,
      },
      {
        'user_id': userId,
        'name': 'Tiết kiệm dài hạn',
        'slug': 'long_term_savings',
        'percentage': 10,
        'icon': 'savings',
        'color': '#3B82F6',
        'is_active': true,
        'balance': 0,
      },
      {
        'user_id': userId,
        'name': 'Giáo dục',
        'slug': 'education',
        'percentage': 10,
        'icon': 'school',
        'color': '#F59E0B',
        'is_active': true,
        'balance': 0,
      },
      {
        'user_id': userId,
        'name': 'Hưởng thụ',
        'slug': 'play',
        'percentage': 10,
        'icon': 'celebration',
        'color': '#8B5CF6',
        'is_active': true,
        'balance': 0,
      },
      {
        'user_id': userId,
        'name': 'Tự do tài chính',
        'slug': 'financial_freedom',
        'percentage': 10,
        'icon': 'account_balance_wallet',
        'color': '#10B981',
        'is_active': true,
        'balance': 0,
      },
      {
        'user_id': userId,
        'name': 'Cho đi',
        'slug': 'give',
        'percentage': 5,
        'icon': 'favorite',
        'color': '#EC4899',
        'is_active': true,
        'balance': 0,
      },
    ];

    await _dataSource.createJars(defaultJars);
  }

  @override
  Future<void> updateJarPercentages({
    required String userId,
    required Map<String, double> jarPercentages,
  }) async {
    for (final entry in jarPercentages.entries) {
      await _dataSource.updateJar(entry.key, {'percentage': entry.value.round()});
    }
  }

  @override
  Future<void> updateJarBalance({
    required String jarId,
    required double balance,
  }) async {
    await _dataSource.updateJar(jarId, {'balance': balance.round()});
  }
}

