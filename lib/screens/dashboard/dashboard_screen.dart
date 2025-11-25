import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/health_record.dart';
import '../../providers/health_records_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/chart_card.dart';
import '../records/records_list_screen.dart';
import '../sleep/sleep_tracker_screen.dart';
import '../bmi/bmi_calculator_screen.dart';
import '../goals/goals_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Removed automatic loading - data loads manually via refresh

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardHomeScreen();
      case 1:
        return const RecordsListScreen();
      case 2:
        return const SleepTrackerScreen();
      case 3:
        return const BMICalculatorScreen();
      case 4:
        return const GoalsScreen();
      default:
        return const DashboardHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nightlight),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Goals',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  // Local state - no provider state management BS
  List<HealthRecord> _allRecords = [];
  HealthRecord? _todayRecord;
  List<HealthRecord> _weeklyRecords = [];
  bool _hasLoadedData = false;
  bool _isLoading = false;

  // No automatic loading - user triggers via refresh

  Future<void> _handleRefresh(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final healthProvider = Provider.of<HealthRecordsProvider>(context, listen: false);
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

      // Load all data - returns data directly, no notifyListeners
      final allRecords = await healthProvider.loadRecords();
      final todayRecord = await healthProvider.loadTodayRecord();
      final weeklyRecords = await healthProvider.getLast7DaysRecords();
      await goalsProvider.loadGoal();

      if (mounted) {
        setState(() {
          _allRecords = allRecords;
          _todayRecord = todayRecord;
          _weeklyRecords = weeklyRecords;
          _hasLoadedData = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data. Pull to refresh.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleLogout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
        child: Consumer<GoalsProvider>(
          builder: (context, goalsProvider, _) {
            // Show empty state if no data loaded yet
            if (!_hasLoadedData) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pull down to load your health data',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Get stats from local state
            final healthProvider = Provider.of<HealthRecordsProvider>(context, listen: false);
            final stats = healthProvider.getTodayStats(_todayRecord);

            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              children: [
                Text(
                  'Today\'s Activity',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Steps',
                      value: '${stats['steps']}',
                      icon: Icons.directions_walk,
                      color: AppColors.stepsColor,
                    ),
                    StatCard(
                      title: 'Calories',
                      value: '${stats['calories']}',
                      icon: Icons.local_fire_department,
                      color: AppColors.caloriesColor,
                    ),
                    StatCard(
                      title: 'Water (ml)',
                      value: '${stats['water']}',
                      icon: Icons.water_drop,
                      color: AppColors.waterColor,
                    ),
                    StatCard(
                      title: 'Sleep Quality',
                      value: _getSleepQuality(context),
                      icon: Icons.bedtime,
                      color: AppColors.sleepColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Goal Progress',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                ProgressStatCard(
                  title: 'Daily Steps Goal',
                  current: stats['steps'] ?? 0,
                  goal: goalsProvider.dailyStepGoal,
                  icon: Icons.directions_walk,
                  color: AppColors.stepsColor,
                ),
                const SizedBox(height: 12),
                ProgressStatCard(
                  title: 'Daily Water Goal',
                  current: stats['water'] ?? 0,
                  goal: goalsProvider.dailyWaterGoalMl,
                  icon: Icons.water_drop,
                  color: AppColors.waterColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Weekly Trends',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                _weeklyRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No data available',
                          style: AppTextStyles.body2,
                        ),
                      )
                    : Column(
                        children: [
                          WeeklyChart(
                            records: _weeklyRecords,
                            dataType: 'steps',
                            color: AppColors.stepsColor,
                          ),
                          const SizedBox(height: 12),
                          WeeklyChart(
                            records: _weeklyRecords,
                            dataType: 'calories',
                            color: AppColors.caloriesColor,
                          ),
                          const SizedBox(height: 12),
                          WeeklyChart(
                            records: _weeklyRecords,
                            dataType: 'water',
                            color: AppColors.waterColor,
                          ),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getSleepQuality(BuildContext context) {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final avgQuality = sleepProvider.getAverageQuality();
    return avgQuality > 0 ? avgQuality.toStringAsFixed(1) : 'N/A';
  }
}
