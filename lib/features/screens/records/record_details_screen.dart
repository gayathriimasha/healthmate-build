import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/helpers.dart';
import '../../../models/health_record.dart';
import '../../../providers/health_records_provider.dart';
import '../../../widgets/custom_button.dart';
import 'add_edit_record_screen.dart';

class RecordDetailsScreen extends StatelessWidget {
  final HealthRecord record;

  const RecordDetailsScreen({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditRecordScreen(record: record),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateCard(),
            const SizedBox(height: 20),
            Text(
              'Health Metrics',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Steps',
              record.steps.toString(),
              'steps taken',
              Icons.directions_walk,
              AppColors.stepsColor,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Calories',
              record.calories.toString(),
              'kcal burned',
              Icons.local_fire_department,
              AppColors.caloriesColor,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Water Intake',
              '${record.water} ml',
              'hydration level',
              Icons.water_drop,
              AppColors.waterColor,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Delete Record',
              onPressed: () => _handleDelete(context),
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightBlue,
            AppColors.pureWhite,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            DateHelper.formatDisplayDate(
              DateHelper.parseDate(record.date),
            ),
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkerSteel,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Health Record',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<HealthRecordsProvider>(context, listen: false);
      final success = await provider.deleteRecord(record.id!);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete record'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
