import 'package:flutter/material.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/presentation/screens/welcome.dart';
import 'package:expenses/presentation/screens/home.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/service/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra auth state khi khởi động app
    final isLoggedIn = AuthService.isLoggedIn;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
