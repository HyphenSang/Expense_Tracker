import '../../data/datasources/supabase_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/jar_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/jar_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Dependency Injection container
/// 
/// Quản lý việc khởi tạo và cung cấp các dependencies cho ứng dụng
class DependencyInjection {
  // Data sources
  static final SupabaseDataSource _supabaseDataSource = SupabaseDataSource();

  // Repositories
  static final AuthRepository _authRepository = AuthRepositoryImpl(_supabaseDataSource);
  static final TransactionRepository _transactionRepository = TransactionRepositoryImpl(_supabaseDataSource);
  static final JarRepository _jarRepository = JarRepositoryImpl(_supabaseDataSource);
  static final WalletRepository _walletRepository = WalletRepositoryImpl(_supabaseDataSource);

  // Getters
  static AuthRepository get authRepository => _authRepository;
  static TransactionRepository get transactionRepository => _transactionRepository;
  static JarRepository get jarRepository => _jarRepository;
  static WalletRepository get walletRepository => _walletRepository;
}

