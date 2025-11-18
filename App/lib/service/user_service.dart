// import 'package:expenses/core/supabase_flutter.dart'; 

// class UserService {
//   static Future<String> getUsernameByEmail(String email) async {
//     final user = await SupabaseConfig.client.from('profiles').select('username').eq('email', email).single();
//     return user['username'] as String? ?? 
//            email.split('@').first ?? 
//            'User';
//   }
// }