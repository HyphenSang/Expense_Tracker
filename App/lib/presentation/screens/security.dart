import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';

/// Màn hình bảo mật - đổi mật khẩu
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdating = false;
  String? _currentPasswordError;

  final _updatePassword = UpdatePassword(DI.authRepository);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePasswordHandler() async {
    // Xóa lỗi cũ trước khi validate
    setState(() {
      _currentPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Validate mật khẩu mới và xác nhận khớp nhau
      if (_newPasswordController.text != _confirmPasswordController.text) {
        throw Exception('Mật khẩu mới và xác nhận không khớp');
      }

      // Cập nhật mật khẩu (sẽ tự động xác thực lại với mật khẩu hiện tại)
      await _updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Xóa form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Quay lại màn hình trước
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // Kiểm tra nếu lỗi liên quan đến mật khẩu hiện tại
      final errorStr = e.toString();
      if (errorStr.contains('Mật khẩu hiện tại không đúng') || 
          errorStr.contains('Invalid login credentials') ||
          errorStr.contains('invalid_credentials')) {
        // Set lỗi vào state để hiển thị ngay dưới trường mật khẩu hiện tại
        setState(() {
          _currentPasswordError = 'Mật khẩu hiện tại không đúng. Vui lòng kiểm tra lại.';
        });
        // Trigger validation lại để hiển thị lỗi
        _formKey.currentState!.validate();
      } else {
        // Các lỗi khác vẫn hiển thị bằng SnackBar
        String errorMessage = 'Không thể đổi mật khẩu';
        if (errorStr.contains('password') && !errorStr.contains('hiện tại')) {
          errorMessage = 'Mật khẩu không hợp lệ. Vui lòng thử lại.';
        } else if (errorStr.contains('network') || errorStr.contains('connection')) {
          errorMessage = 'Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.';
        } else {
          errorMessage = errorStr.replaceAll('Exception: ', '').replaceAll('AuthApiException(message: ', '').replaceAll(')', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo mật'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bảo mật tài khoản',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Đổi mật khẩu để bảo vệ tài khoản của bạn',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl * 2),

                // Mật khẩu hiện tại
                Text(
                  'Mật khẩu hiện tại',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  onChanged: (value) {
                    // Xóa lỗi khi user bắt đầu nhập lại
                    if (_currentPasswordError != null) {
                      setState(() {
                        _currentPasswordError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu hiện tại',
                    border: const OutlineInputBorder(),
                    errorText: _currentPasswordError,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu hiện tại';
                    }
                    // Nếu có lỗi từ API, hiển thị lỗi đó
                    if (_currentPasswordError != null) {
                      return _currentPasswordError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Mật khẩu mới
                Text(
                  'Mật khẩu mới',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Xác nhận mật khẩu mới
                Text(
                  'Xác nhận mật khẩu mới',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu mới',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                    ],
                  ),
                ),
              ),
            ),
            // Nút cập nhật ở dưới cùng
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updatePasswordHandler,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.gray900,
                      disabledBackgroundColor: AppColors.gray300,
                      disabledForegroundColor: AppColors.gray500,
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray900),
                            ),
                          )
                        : Text(
                            'Cập nhật mật khẩu',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

