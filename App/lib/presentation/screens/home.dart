import 'package:flutter/material.dart';
import 'package:expenses/presentation/widgets/bot_nav.dart';
import 'package:expenses/presentation/widgets/total_balance.dart';
import 'package:expenses/service/auth_service.dart';
import 'package:expenses/presentation/widgets/header.dart';
import 'package:expenses/presentation/widgets/quick_stats.dart';
import 'package:expenses/presentation/widgets/recent_transactions.dart';
import 'package:expenses/data/sample_data.dart';
import 'package:expenses/common/theme.dart';
import 'package:expenses/presentation/widgets/jars.dart';
import 'package:expenses/service/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  String _username = 'User';
  bool _isProfileLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = AuthService.getUser();
    if (user == null) return;

    if (mounted) {
      setState(() {
        _isProfileLoading = true;
      });
    }

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
    } finally {
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
      }
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
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [buildSubAppBar(), buildBody()],
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }

  Widget buildSubAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: TotalBalanceSliverDelegate(
        info: TotalBalanceInfo(
          balance: SampleData.totalBalance,
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
          income: SampleData.monthlyIncome,
          expense: SampleData.monthlyExpense,
          saved: SampleData.monthlySaved,
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SixJarsSection(onViewAll: () {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: RecentTransactionsSection(
            dateLabel: SampleData.dateLabel,
            transactions: SampleData.recentTransactions,
            onViewAll: () {},
          ),
        ),
      ]),
    );
  }
}
