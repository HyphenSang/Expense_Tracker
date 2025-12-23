import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

/// Màn hình cài đặt ứng dụng.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.gray500,
          ),
        ),
      ),
    );
  }
}
