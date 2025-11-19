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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen()));
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
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