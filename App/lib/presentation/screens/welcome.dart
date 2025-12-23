/* Dogged AuthScreen because same core services and 
 * states is missing
 * 
 * These missing services and states is getting 
 * anything in database (cause: waitting for admin)
 */ 

import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/p_button.dart';
import 'package:expenses/presentation/screens/auth.dart';
import 'package:expenses/service/auth_service.dart';
import 'package:expenses/presentation/screens/home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final Size media = MediaQuery.sizeOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack ( 
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset('assets/img/welcome_bg.png'),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl + AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('', 
                        width: media.width * 0.5,
                        fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        PrimaryButton(
                          text: 'Get Started',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextButton(
                          onPressed: () async {
                            try {
                              await AuthService.signInWithPassword(
                                email: 'nhiy9130@gmail.com',
                                password: '123456',
                              );
                              // Sau khi đăng nhập thành công, vào thẳng HomeScreen
                              // giao diện, logic, thống kê, ví, hồ sơ... đều là của app thật.
                              // Bỏ toàn bộ màn hình demo cũ.
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            } catch (e) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể đăng nhập vào tài khoản demo: $e',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Dùng nhanh tài khoản mẫu',
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
