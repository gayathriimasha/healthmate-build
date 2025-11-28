import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/bmi_provider.dart';
import '../../widgets/custom_button.dart';

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
                  _buildCategoryCard(provider),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(provider),
                  const SizedBox(height: 20),
                  _buildBMIRangesCard(),
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

  // Direction 3: Card-Based Comparison
  Widget _buildComparisonCards(BMIProvider provider) {
    final categoryColor = _getBMIColor(provider.category);

    return Row(
      children: [
        Expanded(
          child: _buildComparisonCard('18.5', 'Low', AppColors.mutedBlueGrey, false),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildComparisonCard(
            provider.bmi.toStringAsFixed(1),
            'YOU',
            categoryColor,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildComparisonCard('30', 'High', AppColors.accent, false),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(String value, String label, Color color, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: isHighlighted ? AppShadows.elevatedShadow : AppShadows.cardShadow,
        border: isHighlighted ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isHighlighted ? 28 : 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isHighlighted ? color : AppColors.textSecondary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isHighlighted) ...[
            const SizedBox(height: 8),
            Icon(Icons.arrow_upward, color: color, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BMIProvider provider) {
    final categoryColor = _getBMIColor(provider.category);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Category: ',
            style: AppTextStyles.body1,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: categoryColor, width: 1.5),
            ),
            child: Text(
              provider.category,
              style: AppTextStyles.body1.copyWith(
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BMIProvider provider) {
    final categoryColor = _getBMIColor(provider.category);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: AppShadows.cardShadow,
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendation',
                style: AppTextStyles.heading3.copyWith(
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.recommendation,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.darkerSteel,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIRangesCard() {
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
            'BMI Categories',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          _buildBMIRangeItem('Underweight', '< 18.5', AppColors.mutedBlueGrey),
          const SizedBox(height: 12),
          _buildBMIRangeItem('Normal', '18.5 - 24.9', AppColors.primaryBlue),
          const SizedBox(height: 12),
          _buildBMIRangeItem('Overweight', '25.0 - 29.9', AppColors.accent),
          const SizedBox(height: 12),
          _buildBMIRangeItem('Obese', '≥ 30.0', AppColors.darkerSteel),
        ],
      ),
    );
  }

  Widget _buildBMIRangeItem(String category, String range, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(category, style: AppTextStyles.body1),
        ),
        Text(range, style: AppTextStyles.body2),
      ],
    );
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return AppColors.mutedBlueGrey;
      case 'Normal':
        return AppColors.primaryBlue;
      case 'Overweight':
        return AppColors.accent;
      case 'Obese':
        return AppColors.darkerSteel;
      default:
        return AppColors.textPrimary;
    }
  }
}
