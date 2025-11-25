import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';
import '../models/health_record.dart';
import '../core/helpers.dart';

class WeeklyChart extends StatelessWidget {
  final List<HealthRecord> records;
  final String dataType;
  final Color color;

  const WeeklyChart({
    Key? key,
    required this.records,
    required this.dataType,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days - ${_getTitle()}',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: AppTextStyles.body2,
                      ),
                    )
                  : LineChart(_buildLineChartData()),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (dataType) {
      case 'steps':
        return 'Steps';
      case 'calories':
        return 'Calories';
      case 'water':
        return 'Water (ml)';
      default:
        return dataType;
    }
  }

  double _getValue(HealthRecord record) {
    switch (dataType) {
      case 'steps':
        return record.steps.toDouble();
      case 'calories':
        return record.calories.toDouble();
      case 'water':
        return record.water.toDouble();
      default:
        return 0;
    }
  }

  LineChartData _buildLineChartData() {
    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), _getValue(records[i])));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: null,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: AppTextStyles.caption,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < records.length) {
                final date = DateHelper.parseDate(records[value.toInt()].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
