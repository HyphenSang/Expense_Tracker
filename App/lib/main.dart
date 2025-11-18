import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/core/supabase_flutter.dart';
import 'package:expenses/presentation/screens/welcome.dart';
import 'package:expenses/presentation/screens/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
