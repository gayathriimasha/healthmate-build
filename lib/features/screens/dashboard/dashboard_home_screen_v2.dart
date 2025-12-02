import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../models/health_record.dart';
import '../../../providers/health_records_provider.dart';
import '../../../providers/goals_provider.dart';
import '../../../providers/sleep_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/chart_card.dart';
import '../profile/profile_screen.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  HealthRecord? _todayRecord;
  List<HealthRecord> _weeklyRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Auto-load data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final healthProvider = Provider.of<HealthRecordsProvider>(context, listen: false);
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);

    final results = await Future.wait([
      healthProvider.loadTodayRecord(),
      healthProvider.getLast7DaysRecords(),
      goalsProvider.loadGoal(),
      sleepProvider.loadSessions(),
    ]);

    if (mounted) {
      setState(() {
        _todayRecord = results[0] as HealthRecord?;
        _weeklyRecords = results[1] as List<HealthRecord>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                      child: Text(
                        'Today\'s Stats',
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // Direction 2: Top Bar (no card, just text and icon)
  Widget _buildTopBar() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'User';
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    String emoji = '🌅';

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '☀️';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingSmall,
        AppSizes.paddingMedium,
        AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting $emoji',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkerSteel,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Direction 2: 2x2 Grid of bigger stat cards
  Widget _buildStatsGrid() {
    final healthProvider = Provider.of<HealthRecordsProvider>(context, listen: false);
    final stats = healthProvider.getTodayStats(_todayRecord);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Steps',
                  value: '${stats['steps']}',
                  icon: Icons.directions_walk,
                  color: AppColors.stepsColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Calories',
                  value: '${stats['calories']}',
                  icon: Icons.local_fire_department,
                  color: AppColors.caloriesColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Water',
                  value: '${stats['water']} ml',
                  icon: Icons.water_drop,
                  color: AppColors.waterColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Sleep',
                  value: _getSleepQuality(),
                  icon: Icons.bedtime,
                  color: AppColors.sleepColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Direction 2: One medium chart (150px height)
  Widget _buildWeeklyChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: _weeklyRecords.isEmpty
          ? Container(
              height: 150,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                boxShadow: AppShadows.cardShadow,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 40,
                      color: AppColors.mutedBlueGrey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No weekly data yet',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: 250,
              child: WeeklyChart(
                records: _weeklyRecords,
                dataType: 'steps',
                color: AppColors.stepsColor,
              ),
            ),
    );
  }

  String _getSleepQuality() {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final avgQuality = sleepProvider.getAverageQuality();
    return avgQuality > 0 ? avgQuality.toStringAsFixed(1) : 'N/A';
  }
}
