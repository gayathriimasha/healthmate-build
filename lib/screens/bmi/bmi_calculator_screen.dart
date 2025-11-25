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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Height (cm)',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: provider.height,
                                min: 100,
                                max: 250,
                                divisions: 150,
                                label: '${provider.height.toInt()} cm',
                                onChanged: (value) {
                                  provider.setHeight(value);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${provider.height.toInt()}',
                                style: AppTextStyles.heading3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Weight (kg)',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: provider.weight,
                                min: 30,
                                max: 200,
                                divisions: 170,
                                label: '${provider.weight.toInt()} kg',
                                onChanged: (value) {
                                  provider.setWeight(value);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${provider.weight.toInt()}',
                                style: AppTextStyles.heading3,
                                textAlign: TextAlign.center,
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
                  ),
                ),
                if (provider.bmi > 0) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      child: Column(
                        children: [
                          Text(
                            'Your BMI',
                            style: AppTextStyles.body2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.bmi.toStringAsFixed(1),
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 48,
                              color: _getBMIColor(provider.category),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getBMIColor(provider.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              provider.category,
                              style: AppTextStyles.body1.copyWith(
                                color: _getBMIColor(provider.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildBMIScale(provider.bmi),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                'Recommendation',
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.recommendation,
                            style: AppTextStyles.body1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBMIRangesCard(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBMIScale(double bmi) {
    return Column(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF56CCF2),
                Color(0xFF6FCF97),
                Color(0xFFF2C94C),
                Color(0xFFF2994A),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: ((bmi - 10) / 30 * MediaQuery.of(context).size.width * 0.8)
                    .clamp(0, MediaQuery.of(context).size.width * 0.8 - 20),
              ),
              child: Icon(
                Icons.arrow_drop_down,
                color: AppColors.textPrimary,
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10', style: AppTextStyles.caption),
            Text('18.5', style: AppTextStyles.caption),
            Text('25', style: AppTextStyles.caption),
            Text('30', style: AppTextStyles.caption),
            Text('40+', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildBMIRangesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BMI Categories',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            _buildBMIRangeItem(
              'Underweight',
              '< 18.5',
              const Color(0xFF56CCF2),
            ),
            const SizedBox(height: 8),
            _buildBMIRangeItem(
              'Normal',
              '18.5 - 24.9',
              const Color(0xFF6FCF97),
            ),
            const SizedBox(height: 8),
            _buildBMIRangeItem(
              'Overweight',
              '25.0 - 29.9',
              const Color(0xFFF2C94C),
            ),
            const SizedBox(height: 8),
            _buildBMIRangeItem(
              'Obese',
              '≥ 30.0',
              const Color(0xFFF2994A),
            ),
          ],
        ),
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
          child: Text(
            category,
            style: AppTextStyles.body1,
          ),
        ),
        Text(
          range,
          style: AppTextStyles.body2,
        ),
      ],
    );
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return const Color(0xFF56CCF2);
      case 'Normal':
        return const Color(0xFF6FCF97);
      case 'Overweight':
        return const Color(0xFFF2C94C);
      case 'Obese':
        return const Color(0xFFF2994A);
      default:
        return AppColors.textPrimary;
    }
  }
}
