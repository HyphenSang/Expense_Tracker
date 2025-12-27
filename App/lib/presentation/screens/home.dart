import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:expenses/presentation/screens/add_transaction.dart';
import 'package:expenses/presentation/screens/profile.dart';
import 'package:expenses/presentation/screens/wallets.dart';
import 'package:expenses/presentation/screens/transactions_history.dart';
import 'package:expenses/presentation/screens/all_transactions.dart';
import 'package:expenses/presentation/screens/notifications.dart';
import 'package:expenses/presentation/widgets/bot_nav.dart';
import 'package:expenses/presentation/widgets/header.dart';
import 'package:expenses/presentation/widgets/jars.dart';
import 'package:expenses/presentation/widgets/quick_stats.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/presentation/widgets/total_balance.dart';
import 'package:expenses/core/di/di.dart';
import 'package:expenses/domain/features/auth.dart';
import 'package:expenses/domain/features/user.dart';
import 'package:expenses/service/notification_realtime.dart';
import 'package:expenses/domain/features/expense.dart';
import 'package:expenses/domain/repositories/expense.dart' as domain;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  String _username = 'User';
  int _currentIndex = 0;
  domain.ExpenseSummary? _summary;
  List<JarData>? _jars;
  List<TransactionItemData>? _recentTransactions;
  bool _isLoading = true;

  // Use cases
  final _getSummary = GetExpenseSummary(DI.expenseRepository);
  final _getJars = GetJars(DI.expenseRepository);
  final _getTransactions = GetTransactions(DI.expenseRepository);
  final _getCurrentUser = GetCurrentUser(DI.authRepository);
  final _getCurrentUserProfile = GetCurrentUserProfile(DI.userRepository);
  final _ensureCurrentUserProfile = EnsureCurrentUserProfile(DI.userRepository);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadProfile();
    _loadDashboardData();
    // Bắt đầu lắng nghe thông báo real-time
    _startNotificationService();
  }

  Future<void> _startNotificationService() async {
    await NotificationRealtimeService.startListening();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dừng lắng nghe khi dispose
    NotificationRealtimeService.stopListening();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _getCurrentUser();
    if (user == null) return;

    try {
      var profile = await _getCurrentUserProfile();
      profile ??= await _ensureCurrentUserProfile();

      if (!mounted) return;
      final safeProfile = profile;

      setState(() {
        _username =
            safeProfile.username ??
            safeProfile.fullName ??
            safeProfile.userMetadata?['username'] as String? ??
            safeProfile.email?.split('@').first ??
            'User';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin người dùng: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {}
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Đồng bộ jars với total balance trước khi load
      final user = _getCurrentUser();
      if (user != null) {
        try {
          await DI.jarRepository.redistributeJarsByTotalBalance(user.id);
        } catch (e) {
          print('Lỗi khi đồng bộ jars: $e');
          // Không throw để không làm gián đoạn việc load dữ liệu
        }
      }

      // Chạy tất cả API calls song song để tăng tốc độ load
      final results = await Future.wait([
        _getSummary(),
        _getJars(),
        _getTransactions.getRecent(limit: 10),
      ]);

      final summary = results[0] as domain.ExpenseSummary;
      final jars = results[1] as List<JarData>;
      final txs = results[2] as List<TransactionItemData>?;

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _jars = jars;
        _recentTransactions = txs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu tài chính: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser();
    final metadataUsername = user?.userMetadata?['username'] as String?;
    final fallbackUsername =
        metadataUsername ??
        user?.email?.split('@').first ??
        'User';
    final username = _username.isNotEmpty ? _username : fallbackUsername;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: SafeArea(
          child: HomeHeader(
            username: username,
            onProfileTap: _navigateToProfileTab,
            onNotificationsTap: _navigateToNotifications,
          ),
        ),
      ),
      body: _buildBodyForIndex(),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _openAddTransactionSheet();
          } else {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              _loadDashboardData();
            }
          }
        },
      ),
    );
  }

  Widget _buildDashboardScroll() {
    // Hiển thị loading cho toàn bộ màn hình
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    // Hiển thị nội dung khi đã load xong
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [buildSubAppBar(), buildBody()],
    );
  }

  Widget buildSubAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: TotalBalanceSliverDelegate(
        info: TotalBalanceInfo(
          balance: _summary?.totalBalance ?? '',
          isLinked: true,
        ),
        onBankSelect: _navigateToWalletsTab,
      ),
    );
  }

  Widget buildBody() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: AppSpacing.lg),
        QuickStatsSection(
          income: _summary?.monthlyIncome ?? '',
          expense: _summary?.monthlyExpense ?? '',
          saved: _summary?.monthlySaved ?? '',
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SixJarsSection(
            onViewAll: () {},
            jars: _jars ?? const [],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: RecentTransactionsSection(
            dateLabel: 'Hôm nay',
            transactions: _recentTransactions ?? [],
            onViewAll: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AllTransactionsScreen(),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildBodyForIndex() {
    switch (_currentIndex) {
      case 1:
        return const WalletsScreen();
      case 3:
        // Mở màn hình thống kê (TransactionsHistoryScreen với tab Thống kê)
        return const TransactionsHistoryScreen(initialTab: 1);
      case 4:
        return const ProfileScreen();
      case 0:
      default:
        return _buildDashboardScroll();
    }
  }

  /// Điều hướng sang tab Ví/Tài khoản (bottom nav index 1)
  void _navigateToWalletsTab() {
    if (_currentIndex == 1) return;
    setState(() {
      _currentIndex = 1;
    });
  }

  /// Điều hướng sang tab Hồ sơ (bottom nav index 4)
  void _navigateToProfileTab() {
    if (_currentIndex == 4) return;
    setState(() {
      _currentIndex = 4;
    });
  }

  /// Điều hướng đến màn hình Thông báo
  void _navigateToNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  void _openAddTransactionSheet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    
    // Nếu thêm giao dịch thành công, refresh dữ liệu
    if (result == true && mounted) {
      // Đợi một chút để đảm bảo database đã cập nhật
      await Future.delayed(const Duration(milliseconds: 300));
      _loadDashboardData();
    }
  }
}
