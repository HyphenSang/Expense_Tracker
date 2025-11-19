import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/sub_button.dart';
import 'package:expenses/presentation/screens/login.dart';
import 'package:expenses/presentation/screens/regis.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final email = _emailController.text.trim();

    try {
      await SupabaseConfig.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(email: email)),
        );
      }
    } on AuthException catch (authError) {
      final errorMessage = authError.message.toLowerCase();
      final isUserMissing = errorMessage.contains('not found') ||
          errorMessage.contains('signups not allowed');
      if (mounted && isUserMissing) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisScreen(email: email)),
        );
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: ${authError.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: ${e.toString()}'),
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
                                isLoading: _isLoading,
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