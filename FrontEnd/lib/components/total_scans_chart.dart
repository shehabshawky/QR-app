import 'package:flutter/material.dart';
import 'grouped_interval_chart.dart';

class totalScansChart extends StatelessWidget {
  final List<dynamic> totalScans;

  const totalScansChart({
    super.key,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedIntervalChart(
      activityData: totalScans,
      title: 'Total Scans Chart',
      countKey: 'scansCount',
      chartColor: Colors.green,
      chartType: ChartType.line,
      legendLabel: 'Total Scans',
    );
  }
} 