import 'dart:math';

import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _slugify(String input) {
  final trimmed = input.trim().toLowerCase();
  final replaced =
      trimmed.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'-+'), '-');
  final cleaned = replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  if (cleaned.isNotEmpty) return cleaned;
  return 'jar-${DateTime.now().millisecondsSinceEpoch}';
}

class JarModel {
  final String? id;
  final String name;
  final String slug;
  final double percentage;
  final bool isActive;
  final double balance;

  const JarModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.percentage,
    required this.isActive,
    this.balance = 0,
  });

  JarModel copyWith({
    String? id,
    String? name,
    String? slug,
    double? percentage,
    bool? isActive,
    double? balance,
  }) {
    return JarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      percentage: percentage ?? this.percentage,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toInsert(String userId) {
    final safeSlug = slug.isNotEmpty ? slug : _slugify(name);
    return {
      'user_id': userId,
      'name': name,
      'slug': safeSlug,
      'percentage': percentage.round(),
      'is_active': isActive,
      'balance': balance.round(),
    };
  }

  Map<String, dynamic> toUpdate() {
    final safeSlug = slug.isNotEmpty ? slug : _slugify(name);
    return {
      'name': name,
      'slug': safeSlug,
      'percentage': percentage.round(),
      'is_active': isActive,
      'balance': balance.round(),
    };
  }

  static JarModel fromRow(Map<String, dynamic> row) {
    return JarModel(
      id: row['id'] as String?,
      name: (row['name'] as String?) ?? 'Jar',
      slug: (row['slug'] as String?) ?? '',
      percentage: (row['percentage'] as num?)?.toDouble() ?? 0,
      isActive: (row['is_active'] as bool?) ?? true,
      balance: (row['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class JarService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<JarModel>> fetchJars() async {
    final user = AuthService.getUser();
    if (user == null) throw StateError('Chưa đăng nhập');

    final res = await _client
        .from('jars')
        .select('id, name, slug, percentage, is_active, balance')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('created_at');

    return (res as List)
        .map((row) => JarModel.fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// Tự động cân bằng để tổng = 100, ưu tiên giữ “Nhu cầu thiết yếu”.
  static List<JarModel> autoBalance(List<JarModel> jars) {
    // Xét tất cả các hũ đang active (bao gồm cả hũ dự phòng nếu có)
    final activeJars = jars.where((j) => j.isActive).toList();
    if (activeJars.isEmpty) return jars;

    const String essentialSlug = 'necessities';
    final originalEssential = activeJars
        .firstWhere((j) => j.slug == essentialSlug, orElse: () => activeJars[0]);
    JarModel essential = originalEssential;

    var others =
        activeJars.where((j) => j != essential).toList(growable: true);

    // Clamp % âm về 0
    essential = essential.copyWith(percentage: max(0, essential.percentage));
    for (var i = 0; i < others.length; i++) {
      final j = others[i];
      others[i] = j.copyWith(percentage: max(0, j.percentage));
    }

    if (others.isEmpty) {
      // Chỉ còn 1 hũ: cho = 100%
      essential = essential.copyWith(percentage: 100);
      return [
        essential,
        ...jars.where((j) => !j.isActive),
      ];
    }

    // Bước 1: giới hạn trần 55% cho hũ thiết yếu
    double pEssential = min(55, essential.percentage);

    // Bước 2: scale các hũ còn lại để tổng (others) = 100 - pEssential
    final sumOthers = others.fold<double>(0, (p, e) => p + e.percentage);
    final targetOthersTotal = max(0, 100 - pEssential);

    if (sumOthers <= 0) {
      // Nếu các hũ khác đều 0, chia đều phần còn lại
      final per = targetOthersTotal / others.length;
      others = others
          .map((j) => j.copyWith(percentage: per))
          .toList(growable: true);
    } else {
      final factor = targetOthersTotal / sumOthers;
      for (var i = 0; i < others.length; i++) {
        final j = others[i];
        others[i] = j.copyWith(percentage: j.percentage * factor);
      }
    }

    // Cập nhật lại essential theo phần còn thiếu để tổng chính xác = 100
    final othersTotal =
        others.fold<double>(0, (p, e) => p + e.percentage);
    pEssential = 100 - othersTotal;
    essential = essential.copyWith(percentage: pEssential);

    // Nếu do sai số khiến essential > 55 một chút, clamp và scale lại others lần cuối
    if (essential.percentage > 55 + 0.01) {
      final extra = essential.percentage - 55;
      essential = essential.copyWith(percentage: 55);
      others = _redistributeExtra(others, extra);
    }

    // Ghép lại đúng thứ tự ban đầu của các hũ active
    final updatedActive = <JarModel>[];
    var otherIndex = 0;
    for (final j in activeJars) {
      if (j == originalEssential) {
        updatedActive.add(essential);
      } else {
        updatedActive.add(others[otherIndex++]);
      }
    }

    return [
      ...updatedActive,
      ...jars.where((j) => !j.isActive),
    ];
  }

  static List<JarModel> _redistributeExtra(List<JarModel> others, double extra) {
    if (extra <= 0 || others.isEmpty) return others;
    final sum = others.fold(0.0, (p, e) => p + e.percentage);
    if (sum == 0) {
      final per = extra / others.length;
      return others.map((j) => j.copyWith(percentage: j.percentage + per)).toList();
    }
    return others
        .map((j) => j.copyWith(
              percentage: j.percentage + extra * (j.percentage / sum),
            ))
        .toList();
  }

  static Future<void> saveJars({
    required List<JarModel> current,
    required List<String> deleteIds,
  }) async {
    final user = AuthService.getUser();
    if (user == null) throw StateError('Chưa đăng nhập');

    final balanced = autoBalance(current);
    final ensured = balanced
        .map((j) => j.slug.isNotEmpty ? j : j.copyWith(slug: _slugify(j.name)))
        .toList();

    // Re-distribute balances theo % mới cho các hũ active (bỏ reserve)
    final activeJars =
        ensured.where((j) => j.slug != 'reserve' && j.isActive).toList();
    final totalBalance = activeJars.fold<double>(0, (p, e) => p + e.balance);
    List<JarModel> redistrib = ensured;
    if (totalBalance > 0 && activeJars.isNotEmpty) {
      double remaining = totalBalance;
      final updated = <JarModel>[];
      for (var i = 0; i < activeJars.length; i++) {
        final jar = activeJars[i];
        double allocated;
        if (i == activeJars.length - 1) {
          allocated = remaining;
        } else {
          allocated = (totalBalance * jar.percentage / 100);
          allocated = allocated.roundToDouble();
          remaining -= allocated;
        }
        updated.add(jar.copyWith(balance: allocated));
      }
      // merge back
      redistrib = ensured.map((j) {
        final found = updated.firstWhere(
          (u) => u.slug == j.slug && u.name == j.name,
          orElse: () => j,
        );
        return j.copyWith(balance: found.balance);
      }).toList();
    }
    final inserts = <Map<String, dynamic>>[];
    final updates = <Map<String, dynamic>>[];

    for (final jar in redistrib) {
      if (jar.id == null) {
        inserts.add(jar.toInsert(user.id));
      } else {
        updates.add({'id': jar.id, ...jar.toUpdate()});
      }
    }

    for (final id in deleteIds) {
      await _client.from('jars').delete().eq('id', id);
    }

    if (inserts.isNotEmpty) {
      await _client.from('jars').insert(inserts);
    }

    for (final upd in updates) {
      final id = upd.remove('id');
      await _client.from('jars').update(upd).eq('id', id);
    }
  }

}

