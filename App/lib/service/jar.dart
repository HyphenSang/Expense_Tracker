import 'dart:math';

import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/service/auth.dart';
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

  /// Đảm bảo 6 hũ mặc định được tạo cho user (nếu chưa có)
  static Future<void> ensureDefaultJars() async {
    final user = AuthService.getUser();
    if (user == null) throw StateError('Chưa đăng nhập');

    // Kiểm tra xem user đã có hũ chưa
    final existing = await _client
        .from('jars')
        .select('id')
        .eq('user_id', user.id)
        .limit(1);

    if (existing.isEmpty) {
      // Tạo 6 hũ mặc định với tỷ lệ chuẩn theo phương pháp JARS
      final defaultJars = [
        {'name': 'Nhu cầu thiết yếu', 'slug': 'necessities', 'percentage': 55, 'icon': 'home', 'color': '#EF4444'},
        {'name': 'Tiết kiệm dài hạn', 'slug': 'long_term_savings', 'percentage': 10, 'icon': 'savings', 'color': '#3B82F6'},
        {'name': 'Giáo dục', 'slug': 'education', 'percentage': 10, 'icon': 'school', 'color': '#F59E0B'},
        {'name': 'Hưởng thụ', 'slug': 'play', 'percentage': 10, 'icon': 'celebration', 'color': '#8B5CF6'},
        {'name': 'Tự do tài chính', 'slug': 'financial_freedom', 'percentage': 10, 'icon': 'account_balance_wallet', 'color': '#10B981'},
        {'name': 'Cho đi', 'slug': 'give', 'percentage': 5, 'icon': 'favorite', 'color': '#EC4899'},
      ];

      for (final jar in defaultJars) {
        await _client.from('jars').insert({
          'user_id': user.id,
          'name': jar['name'],
          'slug': jar['slug'],
          'percentage': jar['percentage'],
          'balance': 0,
          'icon': jar['icon'],
          'color': jar['color'],
          'is_active': true,
        });
      }
    }
  }

  static Future<List<JarModel>> fetchJars() async {
    final user = AuthService.getUser();
    if (user == null) throw StateError('Chưa đăng nhập');

    // Đảm bảo 6 hũ mặc định được tạo
    await ensureDefaultJars();

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
    // Bỏ qua reserve nếu có slug = 'reserve'
    final activeJars =
        jars.where((j) => j.slug != 'reserve' && j.isActive).toList();
    if (activeJars.isEmpty) return jars;

    const String essentialSlug = 'necessities';
    JarModel? essential = activeJars
        .firstWhere((j) => j.slug == essentialSlug, orElse: () => activeJars[0]);

    var others =
        activeJars.where((j) => j != essential).toList(growable: true);

    double total = activeJars.fold(0, (p, e) => p + e.percentage);
    if (total == 0) {
      // Nếu chưa có % nào, đặt essential = 100
      essential = essential.copyWith(percentage: 100);
      return [
        essential,
        ...others.map((o) => o.copyWith(percentage: 0)),
        ...jars.where((j) => !j.isActive || j.slug == 'reserve'),
      ];
    }

    // Làm tròn xuống nhẹ trước khi cân bằng
    double diff = 100 - total;
    // Nếu diff gần 0, giữ nguyên
    if (diff.abs() <= 0.5) return jars;

    if (diff > 0) {
      // Thiếu %: phân bổ theo tỷ lệ hiện có (ưu tiên essential giữ vai trò lớn)
      final sumAll = essential.percentage + others.fold(0.0, (p, e) => p + e.percentage);
      if (sumAll == 0) {
        essential = essential.copyWith(percentage: essential.percentage + diff);
      } else {
        final addEssential = diff * (essential.percentage / sumAll);
        essential = essential.copyWith(percentage: essential.percentage + addEssential);
        for (var i = 0; i < others.length; i++) {
          final jar = others[i];
          final add = diff * (jar.percentage / sumAll);
          others[i] = jar.copyWith(percentage: jar.percentage + add);
        }
      }
    } else {
      // Thừa %: cắt theo tỷ lệ ở các hũ khác trước; nếu chưa đủ mới cắt essential
      double remainCut = -diff;
      final pool = others.fold(0.0, (p, e) => p + e.percentage);

      if (pool > 0) {
        double reduced = 0;
        for (var i = 0; i < others.length; i++) {
          final jar = others[i];
          final share = jar.percentage / pool;
          final cut = min(jar.percentage, remainCut * share);
          others[i] = jar.copyWith(percentage: jar.percentage - cut);
          reduced += cut;
        }
        remainCut = max(0, remainCut - reduced);
      }

      if (remainCut > 0) {
        final cutEssential = min(essential.percentage, remainCut);
        essential =
            essential.copyWith(percentage: essential.percentage - cutEssential);
        remainCut -= cutEssential;
      }
    }

    // Giới hạn trần 55% cho hũ thiết yếu và phân phối phần dư sang hũ khác
    if (essential.percentage > 55) {
      final extra = essential.percentage - 55;
      essential = essential.copyWith(percentage: 55);
      others = _redistributeExtra(others, extra);
    }

    // Chuẩn hóa lần cuối để đúng 100 chính xác
    double newTotal = essential.percentage + others.fold(0.0, (p, e) => p + e.percentage);
    double adjust = 100 - newTotal;
    
    // Điều chỉnh để tổng = 100 chính xác
    if (adjust.abs() > 0.01) {
      if (adjust > 0) {
        // Thiếu: thêm vào essential nếu chưa đạt trần, nếu không thì vào hũ lớn nhất
        if (essential.percentage < 55) {
          final addToEssential = min(adjust, 55 - essential.percentage);
          essential = essential.copyWith(percentage: essential.percentage + addToEssential);
          adjust -= addToEssential;
        }
        // Nếu còn dư, thêm vào hũ lớn nhất
        if (adjust > 0 && others.isNotEmpty) {
          final largestOther = others.reduce((a, b) => a.percentage > b.percentage ? a : b);
          final largestIndex = others.indexOf(largestOther);
          others[largestIndex] = largestOther.copyWith(percentage: largestOther.percentage + adjust);
        }
      } else {
        // Thừa: giảm từ hũ lớn nhất (không phải essential)
        if (others.isNotEmpty) {
          final largestOther = others.reduce((a, b) => a.percentage > b.percentage ? a : b);
          final largestIndex = others.indexOf(largestOther);
          final cut = min(largestOther.percentage, -adjust);
          others[largestIndex] = largestOther.copyWith(percentage: largestOther.percentage - cut);
          adjust += cut;
        }
        // Nếu vẫn còn thừa, giảm từ essential
        if (adjust < 0) {
          essential = essential.copyWith(percentage: max(0, essential.percentage + adjust));
        }
      }
    }
    
    // Kiểm tra lại tổng cuối cùng (làm tròn để tránh lỗi floating point)
    double finalTotal = essential.percentage + others.fold(0.0, (p, e) => p + e.percentage);
    final finalAdjust = (100 - finalTotal).roundToDouble();
    if (finalAdjust.abs() > 0.01) {
      // Điều chỉnh vào hũ lớn nhất để đảm bảo tổng = 100
      if (finalAdjust > 0 && others.isNotEmpty) {
        final largestOther = others.reduce((a, b) => a.percentage > b.percentage ? a : b);
        final largestIndex = others.indexOf(largestOther);
        others[largestIndex] = largestOther.copyWith(percentage: largestOther.percentage + finalAdjust);
      } else if (finalAdjust < 0 && others.isNotEmpty) {
        final largestOther = others.reduce((a, b) => a.percentage > b.percentage ? a : b);
        final largestIndex = others.indexOf(largestOther);
        others[largestIndex] = largestOther.copyWith(percentage: max(0, largestOther.percentage + finalAdjust));
      }
    }

    return [
      essential,
      ...others,
      ...jars.where((j) => !j.isActive || j.slug == 'reserve'),
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