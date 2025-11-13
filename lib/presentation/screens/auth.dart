import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/screens/home.dart';
import 'package:expenses/presentation/widgets/sub_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            child:SingleChildScrollView(
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
                    SizedBox(height: media.height *0.5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubButton(
                          text: 'Tiếp tục',
                          onPressed: () {
                            // if (_formKey.currentState!.validate()) {
                            // Handle login logic here
                            // }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
    );
  }
}