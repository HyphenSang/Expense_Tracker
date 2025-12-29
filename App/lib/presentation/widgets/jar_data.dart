import 'package:flutter/material.dart';

/// Class chứa dữ liệu cho một hũ tài chính
class JarData {
  final String name;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final double progress;

  JarData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.progress,
  });
}

