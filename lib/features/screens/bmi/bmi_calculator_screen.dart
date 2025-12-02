import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../providers/bmi_provider.dart';
import '../../../widgets/custom_button.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BMIProvider>(context, listen: false).loadSavedValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: Consumer<BMIProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(provider),
                if (provider.bmi > 0) ...[
                  const SizedBox(height: 20),
                  _buildComparisonCards(provider),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(BMIProvider provider) {
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
            'Enter Your Details',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          Text(
            'Height (cm)',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.lightBlue,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withOpacity(0.2),
                    valueIndicatorColor: AppColors.primary,
                  ),
                  child: Slider(
                    value: provider.height,
                    min: 100,
                    max: 250,
                    divisions: 150,
                    label: '${provider.height.toInt()} cm',
                    onChanged: (value) => provider.setHeight(value),
                  ),
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '${provider.height.toInt()}',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Weight (kg)',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.lightBlue,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withOpacity(0.2),
                    valueIndicatorColor: AppColors.primary,
                  ),
                  child: Slider(
                    value: provider.weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    label: '${provider.weight.toInt()} kg',
                    onChanged: (value) => provider.setWeight(value),
                  ),
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '${provider.weight.toInt()}',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Calculate BMI',
            onPressed: provider.calculateBMI,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCards(BMIProvider provider) {
    final categoryColor = _getBMIColor(provider.category);
    final bmiValue = provider.bmi;

    // BMI ranges
    const double maxBMI = 40.0; // Max for visualization

    // Calculate position (0-1)
    double normalizedBMI = (bmiValue.clamp(10, maxBMI) - 10) / (maxBMI - 10);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your BMI',
                style: AppTextStyles.heading3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categoryColor, width: 2),
                ),
                child: Text(
                  provider.bmi.toStringAsFixed(1),
                  style: AppTextStyles.heading2.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar with gradient
          Stack(
            children: [
              // Background gradient bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.bmiUnderweight,
                      AppColors.bmiNormal,
                      AppColors.bmiOverweight,
                      AppColors.bmiObese,
                    ],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                ),
              ),
              // Indicator
              Positioned(
                left: MediaQuery.of(context).size.width * normalizedBMI * 0.75,
                top: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pureWhite, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBMILabel('Underweight', '< 18.5', AppColors.bmiUnderweight),
              _buildBMILabel('Normal', '18.5-24.9', AppColors.bmiNormal),
              _buildBMILabel('Overweight', '25-29.9', AppColors.bmiOverweight),
              _buildBMILabel('Obese', '≥ 30', AppColors.bmiObese),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMILabel(String category, String range, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          range,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(BMIProvider provider) {
    final categoryColor = _getBMIColor(provider.category);

    // Get icon and title based on category
    IconData categoryIcon;
    String categoryTitle;

    switch (provider.category) {
      case 'Underweight':
        categoryIcon = Icons.trending_down;
        categoryTitle = 'Underweight';
        break;
      case 'Normal':
        categoryIcon = Icons.check_circle;
        categoryTitle = 'Healthy Weight';
        break;
      case 'Overweight':
        categoryIcon = Icons.warning_amber_rounded;
        categoryTitle = 'Overweight';
        break;
      case 'Obese':
        categoryIcon = Icons.error;
        categoryTitle = 'Obese';
        break;
      default:
        categoryIcon = Icons.info;
        categoryTitle = provider.category;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Status',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryTitle,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: categoryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommendation',
                      style: AppTextStyles.heading3.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  provider.recommendation,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.darkerSteel,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return AppColors.bmiUnderweight;
      case 'Normal':
        return AppColors.bmiNormal;
      case 'Overweight':
        return AppColors.bmiOverweight;
      case 'Obese':
        return AppColors.bmiObese;
      default:
        return AppColors.textPrimary;
    }
  }
}
