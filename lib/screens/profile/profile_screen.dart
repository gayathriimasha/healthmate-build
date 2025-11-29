import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goals_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, user?.name ?? 'User'),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildGoalsSection(context),
                const SizedBox(height: 20),
                _buildStatsCards(context),
                const SizedBox(height: 20),
                _buildSettingsSection(context),
                const SizedBox(height: 16),
                _buildAboutSection(),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.darkerSteel,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 3),
                  boxShadow: AppShadows.elevatedShadow,
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 36,
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Health Enthusiast',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.pureWhite.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Goals',
                  style: AppTextStyles.heading3,
                ),
                Icon(
                  Icons.flag_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildGoalTile(
            context,
            icon: Icons.directions_walk,
            title: 'Daily Step Goal',
            value: '${goalsProvider.dailyStepGoal} steps',
            color: AppColors.stepsColor,
            onTap: () => _showEditGoalDialog(
              context,
              'Step Goal',
              'Enter your daily step goal',
              goalsProvider.dailyStepGoal.toString(),
              (value) {
                final intValue = int.tryParse(value);
                if (intValue != null) {
                  goalsProvider.updateGoal(
                    intValue,
                    goalsProvider.dailyWaterGoalMl,
                    goalsProvider.targetWeight,
                  );
                }
              },
              isInt: true,
            ),
          ),
          _buildGoalTile(
            context,
            icon: Icons.water_drop,
            title: 'Daily Water Goal',
            value: '${goalsProvider.dailyWaterGoalMl} ml',
            color: AppColors.waterColor,
            onTap: () => _showEditGoalDialog(
              context,
              'Water Goal',
              'Enter your daily water goal (ml)',
              goalsProvider.dailyWaterGoalMl.toString(),
              (value) {
                final intValue = int.tryParse(value);
                if (intValue != null) {
                  goalsProvider.updateGoal(
                    goalsProvider.dailyStepGoal,
                    intValue,
                    goalsProvider.targetWeight,
                  );
                }
              },
              isInt: true,
            ),
          ),
          _buildGoalTile(
            context,
            icon: Icons.monitor_weight,
            title: 'Target Weight',
            value: '${goalsProvider.targetWeight.toStringAsFixed(1)} kg',
            color: AppColors.accent,
            onTap: () => _showEditGoalDialog(
              context,
              'Target Weight',
              'Enter your target weight (kg)',
              goalsProvider.targetWeight.toString(),
              (value) {
                final doubleValue = double.tryParse(value);
                if (doubleValue != null) {
                  goalsProvider.updateGoal(
                    goalsProvider.dailyStepGoal,
                    goalsProvider.dailyWaterGoalMl,
                    doubleValue,
                  );
                }
              },
              isInt: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialog(
    BuildContext context,
    String title,
    String hint,
    String currentValue,
    Function(String) onSave,
    {required bool isInt}
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                onSave(value);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title updated successfully'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Step Goal',
            '${goalsProvider.dailyStepGoal}',
            Icons.directions_walk,
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Daily Goal',
            '${goalsProvider.dailyStepGoal}',
            Icons.flag,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'Settings',
              style: AppTextStyles.heading3,
            ),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            Icons.person_outline,
            'Edit Profile',
            () {},
          ),
          _buildSettingsTile(
            Icons.notifications_outlined,
            'Notifications',
            () {},
          ),
          _buildSettingsTile(
            Icons.privacy_tip_outlined,
            'Privacy',
            () {},
          ),
          _buildSettingsTile(
            Icons.help_outline,
            'Help & Support',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About HealthMate',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 12),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal health companion for tracking wellness goals and maintaining a healthy lifestyle.',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: OutlinedButton.icon(
        onPressed: () {
          _handleLogout(context);
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
