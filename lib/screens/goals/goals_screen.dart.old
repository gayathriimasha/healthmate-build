import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../providers/goals_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepGoalController = TextEditingController();
  final _waterGoalController = TextEditingController();
  final _targetWeightController = TextEditingController();

  bool _hasLoadedGoals = false;

  void _loadGoalsIfNeeded() {
    if (_hasLoadedGoals) return;

    final provider = Provider.of<GoalsProvider>(context, listen: false);

    // Wait if provider is still loading from parent
    if (provider.isLoading) {
      return;
    }

    _hasLoadedGoals = true;

    // Use microtask to ensure we're outside any build cycle
    Future.microtask(() {
      if (!mounted) return;
      _stepGoalController.text = provider.dailyStepGoal.toString();
      _waterGoalController.text = provider.dailyWaterGoalMl.toString();
      _targetWeightController.text = provider.targetWeight.toString();
    });
  }

  @override
  void dispose() {
    _stepGoalController.dispose();
    _waterGoalController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<GoalsProvider>(context, listen: false);
    final success = await provider.updateGoal(
      int.parse(_stepGoalController.text),
      int.parse(_waterGoalController.text),
      double.parse(_targetWeightController.text),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goals updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update goals'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals & Settings'),
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, _) {
          // Load goals after provider finishes loading
          if (!provider.isLoading) {
            _loadGoalsIfNeeded();
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Daily Goals',
                                style: AppTextStyles.heading2,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Daily Step Goal',
                            hint: 'Enter target steps per day',
                            controller: _stepGoalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) =>
                                ValidationHelper.validateNumber(value, 'Step goal'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Daily Water Goal (ml)',
                            hint: 'Enter target water intake in ml',
                            controller: _waterGoalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) =>
                                ValidationHelper.validateNumber(value, 'Water goal'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Target Weight (kg)',
                            hint: 'Enter your target weight',
                            controller: _targetWeightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                ValidationHelper.validateDouble(value, 'Target weight'),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Save Goals',
                            onPressed: _handleSave,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Goals',
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildGoalInfoItem(
                            'Daily Steps',
                            '${provider.dailyStepGoal} steps',
                            Icons.directions_walk,
                            AppColors.stepsColor,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalInfoItem(
                            'Daily Water',
                            '${provider.dailyWaterGoalMl} ml',
                            Icons.water_drop,
                            AppColors.waterColor,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalInfoItem(
                            'Target Weight',
                            '${provider.targetWeight.toStringAsFixed(1)} kg',
                            Icons.monitor_weight,
                            AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Daily Goals',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendationItem(
                            'Steps: 10,000 steps/day for general health',
                          ),
                          const SizedBox(height: 8),
                          _buildRecommendationItem(
                            'Water: 2,000-2,500 ml/day for adults',
                          ),
                          const SizedBox(height: 8),
                          _buildRecommendationItem(
                            'Weight: Consult BMI calculator for healthy range',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body2),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2,
          ),
        ),
      ],
    );
  }
}
