import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';

class PasswordStrengthData {
  final double strength;
  final bool hasMinLength;
  final bool hasUpperCase;
  final bool hasNumber;
  final bool hasSpecialChar;

  PasswordStrengthData({
    required this.strength,
    required this.hasMinLength,
    required this.hasUpperCase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  bool get isValid => hasMinLength && hasUpperCase && hasNumber && hasSpecialChar;
}

class PasswordStrengthIndicator extends StatefulWidget {
  final TextEditingController passwordController;
  final ValueChanged<PasswordStrengthData>? onStrengthChanged;

  const PasswordStrengthIndicator({
    super.key,
    required this.passwordController,
    this.onStrengthChanged,
  });

  @override
  State<PasswordStrengthIndicator> createState() => _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  PasswordStrengthData _strengthData = PasswordStrengthData(
    strength: 0.0,
    hasMinLength: false,
    hasUpperCase: false,
    hasNumber: false,
    hasSpecialChar: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.passwordController.addListener(_checkPasswordStrength);
    });
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_checkPasswordStrength);
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = widget.passwordController.text;
    
    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int criteriaMet = 0;
    if (hasMinLength) criteriaMet++;
    if (hasUpperCase) criteriaMet++;
    if (hasNumber) criteriaMet++;
    if (hasSpecialChar) criteriaMet++;
    
    final strength = criteriaMet / 4.0;
    
    final newData = PasswordStrengthData(
      strength: strength,
      hasMinLength: hasMinLength,
      hasUpperCase: hasUpperCase,
      hasNumber: hasNumber,
      hasSpecialChar: hasSpecialChar,
    );

    if (mounted) {
      setState(() {
        _strengthData = newData;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onStrengthChanged?.call(newData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thanh đo độ bảo mật
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strengthData.strength,
                  minHeight: 6,
                  backgroundColor: AppColors.gray300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _strengthData.strength < 0.4
                        ? Colors.red
                        : _strengthData.strength < 0.7
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              _strengthData.strength <= 0.0
                  ? ''
                  : _strengthData.strength < 0.4
                      ? 'Yếu'
                      : _strengthData.strength < 0.7
                          ? 'Trung bình'
                          : 'Mạnh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _strengthData.strength < 0.4
                              ? Colors.red
                              : _strengthData.strength < 0.7
                                  ? Colors.orange
                                  : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        // Yêu cầu mật khẩu
        Text(
          'Yêu cầu mật khẩu:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildRequirementItem('Ít nhất 8 ký tự', _strengthData.hasMinLength),
        SizedBox(height: AppSpacing.xs),
        _buildRequirementItem('Có chữ hoa (A-Z)', _strengthData.hasUpperCase),
        SizedBox(height: AppSpacing.xs),
        _buildRequirementItem('Có số (0-9)', _strengthData.hasNumber),
        SizedBox(height: AppSpacing.xs),
        _buildRequirementItem('Có ký tự đặc biệt (!@#\$%...)', _strengthData.hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? Colors.green : AppColors.gray400,
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isMet ? Colors.green : AppColors.gray500,
                  decoration: isMet ? null : TextDecoration.none,
                ),
          ),
        ),
      ],
    );
  }
}

