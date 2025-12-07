import 'package:flutter/material.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:expenses/presentation/screens/add_transaction.dart';
import 'package:expenses/presentation/screens/profile.dart';
import 'package:expenses/presentation/screens/wallets.dart';
import 'package:expenses/presentation/screens/transactions_history.dart';
import 'package:expenses/presentation/screens/all_transactions.dart';
import 'package:expenses/presentation/widgets/bot_nav.dart';
import 'package:expenses/presentation/widgets/header.dart';
import 'package:expenses/presentation/widgets/jars.dart';
import 'package:expenses/presentation/widgets/quick_stats.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/presentation/widgets/total_balance.dart';
import 'package:expenses/service/auth_service.dart';
import 'package:expenses/service/expense_service.dart';
import 'package:expenses/service/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  String _username = 'User';
  int _currentIndex = 0;
  ExpenseSummary? _summary;
  List<JarData>? _jars;
  List<TransactionItemData>? _recentTransactions;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadProfile();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.getUser();
    if (user == null) return;

    try {
      var profile = await UserService.getCurrentUserProfile();
      profile ??= await UserService.ensureCurrentUserProfile();

      if (!mounted) return;
      final safeProfile = profile;

      setState(() {
        _username =
            safeProfile.username ??
            safeProfile.fullName ??
            user.userMetadata?['username'] as String? ??
            user.email?.split('@').first ??
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
    try {
      final summary = await ExpenseService.getSummary();
      final jars = await ExpenseService.getJars();
      final txs = await ExpenseService.getRecentTransactions(limit: 10);

      if (!mounted) return;

      setState(() {
        _summary = summary;
        _jars = jars;
        _recentTransactions = txs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu tài chính, đang dùng dữ liệu mẫu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadataUsername =
        AuthService.getUser()?.userMetadata?['username'] as String?;
    final fallbackUsername =
        metadataUsername ??
        AuthService.getUser()?.email?.split('@').first ??
        'User';
    final username = _username.isNotEmpty ? _username : fallbackUsername;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: SafeArea(child: HomeHeader(username: username)),
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
          }
        },
      ),
    );
  }

  Widget _buildDashboardScroll() {
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
          balance: _summary?.totalBalance ?? SampleData.totalBalance,
          isLinked: true,
        ),
        onBankSelect: () {},
      ),
    );
  }

  Widget buildBody() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: AppSpacing.lg),
        QuickStatsSection(
          income: _summary?.monthlyIncome ?? SampleData.monthlyIncome,
          expense: _summary?.monthlyExpense ?? SampleData.monthlyExpense,
          saved: _summary?.monthlySaved ?? SampleData.monthlySaved,
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
            dateLabel: SampleData.dateLabel,
            transactions:
                _recentTransactions ?? SampleData.recentTransactions,
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

  void _openAddTransactionSheet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    
    // Nếu thêm giao dịch thành công, refresh dữ liệu
    if (result == true && mounted) {
      _loadDashboardData();
    }
  }
}
