import 'package:flutter/material.dart';
import 'grouped_interval_chart.dart';

class TotalRevenueChart extends StatelessWidget {
  final List<dynamic> revenueData;

  const TotalRevenueChart({
    super.key,
    required this.revenueData,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedIntervalChart(
      activityData: revenueData,
      title: 'Total Revenue Chart',
      countKey: 'revenue',
      chartColor: Colors.blue,
      chartType: ChartType.line,
      legendLabel: 'Total Revenue',
      showCurrency: true,
    );
  }
} 