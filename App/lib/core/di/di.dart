import '../../data/datasources/supabase.dart';
import '../../data/repositories/auth.dart';
import '../../data/repositories/transaction.dart';
import '../../data/repositories/jar.dart';
import '../../data/repositories/wallet.dart';
import '../../data/repositories/preference.dart';
import '../../data/repositories/user.dart';
import '../../data/repositories/notification.dart';
import '../../domain/repositories/auth.dart' as domain;
import '../../domain/repositories/transaction.dart' as domain_transaction;
import '../../domain/repositories/jar.dart' as domain_jar;
import '../../domain/repositories/wallet.dart' as domain_wallet;
import '../../domain/repositories/preference.dart' as domain_preference;
import '../../domain/repositories/user.dart' as domain_user;
import '../../domain/repositories/notification.dart' as domain_notification;

/// Dependency Injection container
/// 
/// Quản lý việc khởi tạo và cung cấp các dependencies cho ứng dụng
class DI {
  // Data sources
  static final SupabaseDataSource _supabaseDataSource = SupabaseDataSource();

  // Repositories
  static final domain.AuthRepository _authRepository = AuthRepositoryImpl(_supabaseDataSource);
  static final domain_transaction.TransactionRepository _transactionRepository = TransactionRepositoryImpl(_supabaseDataSource);
  static final domain_jar.JarRepository _jarRepository = JarRepositoryImpl(_supabaseDataSource);
  static final domain_wallet.WalletRepository _walletRepository = WalletRepositoryImpl(_supabaseDataSource);
  static final domain_preference.PreferenceRepository _preferenceRepository = PreferenceRepositoryImpl();
  static final domain_user.UserRepository _userRepository = UserRepositoryImpl(_supabaseDataSource);
  static final domain_notification.NotificationRepository _notificationRepository = NotificationRepositoryImpl();

  // Getters
  static domain.AuthRepository get authRepository => _authRepository;
  static domain_transaction.TransactionRepository get transactionRepository => _transactionRepository;
  static domain_jar.JarRepository get jarRepository => _jarRepository;
  static domain_wallet.WalletRepository get walletRepository => _walletRepository;
  static domain_preference.PreferenceRepository get preferenceRepository => _preferenceRepository;
  static domain_user.UserRepository get userRepository => _userRepository;
  static domain_notification.NotificationRepository get notificationRepository => _notificationRepository;
}

