import 'package:flutter/material.dart';
import 'grouped_interval_chart.dart';

class TotalLostRevenueChart extends StatelessWidget {
  final List<dynamic> lostRevenueData;

  const TotalLostRevenueChart({
    super.key,
    required this.lostRevenueData,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedIntervalChart(
      activityData: lostRevenueData,
      title: 'Total Lost Revenue Chart',
      countKey: 'revenueLost',
      chartColor: Colors.orange,
      chartType: ChartType.line,
      legendLabel: 'Lost Revenue',
      showCurrency: true,
    );
  }
} 