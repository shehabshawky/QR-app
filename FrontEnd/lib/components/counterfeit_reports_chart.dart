import 'package:flutter/material.dart';
import 'grouped_interval_chart.dart';

class CounterfeitReportsChart extends StatelessWidget {
  final List<dynamic> reportsData;

  const CounterfeitReportsChart({
    super.key,
    required this.reportsData,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedIntervalChart(
      activityData: reportsData,
      title: 'Counterfeit Reports Chart',
      countKey: 'reportsCount',
      chartColor: Colors.red,
      chartType: ChartType.line,
      legendLabel: 'Counterfeit Reports',
    );
  }
} 