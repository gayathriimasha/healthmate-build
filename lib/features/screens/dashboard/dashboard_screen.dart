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
import '../records/records_list_screen.dart';
import '../sleep/sleep_tracker_screen.dart';
import '../bmi/bmi_calculator_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_home_screen_v2.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
        return const ProfileScreen();
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime),
            label: 'Sleep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
