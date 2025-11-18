import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/home.dart';
import 'package:expenses/presentation/widgets/sub_button.dart';
import 'package:expenses/presentation/state/password_strength_indicator.dart';
import 'package:expenses/service/auth_service.dart';

class RegisScreen extends StatefulWidget {
  final String email;
  const RegisScreen({super.key, required this.email});

  @override
  State<RegisScreen> createState() => _RegisScreenState();
}

class _RegisScreenState extends State<RegisScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PasswordStrengthData? _passwordStrengthData;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Register new user
  Future<void> _regis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.signUp(
        email: widget.email.isNotEmpty
            ? widget.email
            : _usernameController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (response.user != null && mounted) {
        // Register successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack ( 
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset('assets/img/auth_bg.png'),
          ),
          SafeArea(
            child:CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl + AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: media.height * 0.1),
                          Text(
                            'Chào, ${_usernameController.text.isEmpty ? "bạn" : _usernameController.text}!',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Bạn là người mới? Hãy nhập mật khẩu để đăng ký',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.w400,
                                ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          TextFormField(
                            controller: _usernameController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Tên người dùng',
                              hintText: 'Nhập tên người dùng',
                              prefixIcon: const Icon(Icons.person_outlined),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên người dùng';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu của bạn',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (_passwordStrengthData == null) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (!_passwordStrengthData!.hasMinLength) {
                                return 'Mật khẩu phải có ít nhất 8 ký tự';
                              }
                              if (!_passwordStrengthData!.hasUpperCase) {
                                return 'Mật khẩu phải có chữ hoa';
                              }
                              if (!_passwordStrengthData!.hasNumber) {
                                return 'Mật khẩu phải có ít nhất một số';
                              }
                              if (!_passwordStrengthData!.hasSpecialChar) {
                                return 'Mật khẩu phải có ít nhất một ký tự đặc biệt';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.md),
                          PasswordStrengthIndicator(
                            passwordController: _passwordController,
                            onStrengthChanged: (data) {
                              setState(() {
                                _passwordStrengthData = data;
                              });
                            },
                          ),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SubButton(
                                text: 'Đăng ký',
                                isLoading: _isLoading,
                                onPressed: () {
                                  _regis();
                                },
                              ),
                              SizedBox(height: AppSpacing.xxl),
                              Text(
                                'Bằng việc đăng ký, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      )
    );
  }
}