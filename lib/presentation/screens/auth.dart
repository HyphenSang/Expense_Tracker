import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/sub_button.dart';
import 'package:expenses/presentation/screens/login.dart';
import 'package:expenses/presentation/screens/regis.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Check if email exists in the system
  Future<void> _checkEmailAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra xem email đã được đăng ký chưa
      // Bạn có thể sử dụng Supabase để kiểm tra trong database
      // Hoặc thử đăng nhập với email này (nếu lỗi thì chưa có tài khoản)
      
      // Ví dụ: Thử đăng nhập với password rỗng để kiểm tra email
      // (Cách này không an toàn, chỉ là ví dụ)
      // Trong thực tế, bạn nên có một API endpoint riêng để kiểm tra
      
      // Tạm thời chuyển đến màn hình đăng ký
      // Bạn có thể thay đổi logic này dựa trên yêu cầu của bạn
      final email = _emailController.text.trim();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisScreen(
              email: email,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
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
                            'Expenses xin chào!',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Nhập email để đăng nhập hoặc đăng ký',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.w400,
                                ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: AppSpacing.xxl),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Nhập email của bạn',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!value.contains('@')) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SubButton(
                                text: 'Tiếp tục',
                                onPressed: () {
                                  _checkEmailAndContinue();
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