import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/home.dart';
import 'package:expenses/presentation/widgets/sub_button.dart';
import 'package:expenses/presentation/state/password_strength_indicator.dart';

class RegisScreen extends StatefulWidget {
  const RegisScreen({super.key});

  @override
  State<RegisScreen> createState() => _RegisScreenState();
}

class _RegisScreenState extends State<RegisScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PasswordStrengthData? _passwordStrengthData;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _regis() {
    if (_formKey.currentState!.validate()) {
      // Handle registration logic here
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
                            'Chào, ${_usernameController.text} !',
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
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu của bạn',
                              prefixIcon: const Icon(Icons.lock_outlined),
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
                                text: 'Đăng nhập',
                                onPressed: () {
                                  _regis();
                                },
                              ),
                              SizedBox(height: AppSpacing.xxl),
                              Text(
                                'Bằng việc đăng nhập, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi',
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