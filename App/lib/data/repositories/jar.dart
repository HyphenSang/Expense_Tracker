import '../../domain/entities/jar.dart';
import '../../domain/repositories/jar.dart' as domain;
import '../datasources/supabase.dart';
import '../models/jar.dart';

/// Implementation của JarRepository
class JarRepositoryImpl implements domain.JarRepository {
  final SupabaseDataSource _dataSource;

  JarRepositoryImpl(this._dataSource);

  @override
  Future<List<JarEntity>> getJars(String userId) async {
    final data = await _dataSource.getJars(userId);
    return data.map((json) => JarModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<List<JarEntity>> getAllJars(String userId) async {
    final data = await _dataSource.getAllJars(userId);
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

  @override
  Future<JarEntity> createJar({
    required String userId,
    required String name,
    required String slug,
    required int percentage,
    String? icon,
    String? color,
    String? description,
    double? targetAmount,
  }) async {
    final jarData = {
      'user_id': userId,
      'name': name,
      'slug': slug,
      'percentage': percentage,
      'icon': icon,
      'color': color ?? '#6B7280',
      'description': description,
      'target_amount': targetAmount,
      'balance': 0,
      'is_active': true,
    };
    final result = await _dataSource.createJar(jarData);
    return JarModel.fromJson(result).toEntity();
  }

  @override
  Future<void> updateJar({
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
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (slug != null) data['slug'] = slug;
    if (percentage != null) data['percentage'] = percentage;
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;
    if (description != null) data['description'] = description;
    if (targetAmount != null) data['target_amount'] = targetAmount;
    if (isActive != null) data['is_active'] = isActive;

    if (data.isNotEmpty) {
      await _dataSource.updateJar(jarId, data);
    }
  }

  @override
  Future<void> deleteJar(String jarId) async {
    await _dataSource.deleteJar(jarId);
  }

  @override
  Future<void> redistributeJarsByTotalBalance(String userId) async {
    try {
      // Đảm bảo có jars mặc định trước khi chia lại
      await ensureDefaultJars(userId);

      // Lấy total balance từ tất cả wallets đang hoạt động
      final wallets = await _dataSource.getWallets(userId);
      num totalBalance = 0;
      for (final wallet in wallets) {
        totalBalance += (wallet['balance'] as num?) ?? 0;
      }

      // Lấy danh sách tất cả các hũ (bao gồm cả không active)
      final allJars = await _dataSource.getAllJars(userId);
      final activeJars = allJars.where((j) => (j['is_active'] as bool?) ?? true).toList();

      if (activeJars.isEmpty) {
        // Nếu không có hũ active, không làm gì
        return;
      }

      if (totalBalance <= 0) {
        // Nếu total balance = 0, set balance = 0 cho tất cả hũ
        for (final jar in allJars) {
          await _dataSource.updateJar(jar['id'] as String, {'balance': 0});
        }
        return;
      }

      // Chia lại theo %: jar.balance = totalBalance * jar.percentage / 100
      num remaining = totalBalance;
      for (var i = 0; i < activeJars.length; i++) {
        final jar = activeJars[i];
        final jarId = jar['id'] as String;
        final percentage = (jar['percentage'] as num?) ?? 0;
        
        num allocated;
        if (i == activeJars.length - 1) {
          // Hũ cuối cùng nhận phần còn lại để đảm bảo tổng = totalBalance
          allocated = remaining;
        } else {
          allocated = (totalBalance * percentage / 100).round();
          remaining -= allocated;
        }

        await _dataSource.updateJar(jarId, {'balance': allocated});
      }
    } catch (e) {
      // Log lỗi nhưng không throw để không làm gián đoạn flow
      rethrow;
    }
  }
}

