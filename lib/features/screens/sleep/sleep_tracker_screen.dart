import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/helpers.dart';
import '../../../models/sleep_session.dart';
import '../../../providers/sleep_provider.dart';
import '../../../widgets/custom_button.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({Key? key}) : super(key: key);

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime? _startTime;
  DateTime? _endTime;
  int _quality = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
      ),
      body: Consumer<SleepProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAddSessionCard(),
                const SizedBox(height: 20),
                _buildStatisticsCard(provider),
                const SizedBox(height: 20),
                Text(
                  'Sleep History',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
                if (provider.sessions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bedtime_outlined,
                            size: 64,
                            color: AppColors.mutedBlueGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sleep sessions yet',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.sessions.length,
                    itemBuilder: (context, index) {
                      final session = provider.sessions[index];
                      return _buildSessionCard(session, provider);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddSessionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Sleep Session',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          _buildTimePicker(
            label: 'Start Time',
            time: _startTime,
            onSelect: (time) {
              setState(() {
                _startTime = time;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTimePicker(
            label: 'End Time',
            time: _endTime,
            onSelect: (time) {
              setState(() {
                _endTime = time;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Sleep Quality',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final quality = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _quality = quality;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: quality <= _quality
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        size: 28,
                        color: quality <= _quality
                            ? AppColors.accent
                            : AppColors.lightGreyBg,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quality',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Session',
            onPressed: _handleAddSession,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime? time,
    required Function(DateTime) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: time ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 7)),
              lastDate: DateTime.now(),
            );
            if (date != null && mounted) {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(time ?? DateTime.now()),
              );
              if (selectedTime != null) {
                onSelect(DateTime(
                  date.year,
                  date.month,
                  date.day,
                  selectedTime.hour,
                  selectedTime.minute,
                ));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  time != null
                      ? DateHelper.formatDateTime(time)
                      : 'Select $label',
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(SleepProvider provider) {
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
          Text(
            'Sleep Statistics',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avg Duration',
                SleepHelper.formatDuration(
                  provider.getAverageDuration().toInt(),
                ),
                Icons.bedtime,
                AppColors.primaryBlue,
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.lightGreyBg,
              ),
              _buildStatItem(
                'Avg Quality',
                provider.getAverageQuality().toStringAsFixed(1),
                Icons.star,
                AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildSessionCard(SleepSession session, SleepProvider provider) {
    final startTime = DateTime.fromMillisecondsSinceEpoch(session.startTime);
    final endTime = DateTime.fromMillisecondsSinceEpoch(session.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.bedtime,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateHelper.formatDisplayDate(startTime),
                  style: AppTextStyles.heading3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateHelper.formatTime(startTime)} - ${DateHelper.formatTime(endTime)}',
                  style: AppTextStyles.body2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timelapse, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      SleepHelper.formatDuration(session.durationMinutes),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.star, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      '${session.quality}/5',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => _handleDelete(session.id!, provider),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddSession() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final duration = SleepHelper.calculateDuration(_startTime!, _endTime!);
    final session = SleepSession(
      startTime: _startTime!.millisecondsSinceEpoch,
      endTime: _endTime!.millisecondsSinceEpoch,
      durationMinutes: duration,
      quality: _quality,
      date: DateHelper.formatDate(_endTime!),
    );

    final provider = Provider.of<SleepProvider>(context, listen: false);
    final success = await provider.addSession(session);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep session added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _startTime = null;
        _endTime = null;
        _quality = 3;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add session'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleDelete(int id, SleepProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text('Are you sure you want to delete this sleep session?'),
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

    if (confirmed == true) {
      final success = await provider.deleteSession(id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
