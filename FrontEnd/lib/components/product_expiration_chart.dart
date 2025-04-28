import 'package:flutter/material.dart';
import 'grouped_interval_chart.dart';

class ProductExpirationChart extends StatelessWidget {
  final List<dynamic> expirationData;

  const ProductExpirationChart({
    super.key,
    required this.expirationData,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedIntervalChart(
      activityData: expirationData,
      title: 'Products Expiration Date',
      countKey: 'expiredCount',
      chartColor: const Color(0xFF818CF8), // Indigo color for bars
      chartType: ChartType.bar,
      legendLabel: 'Product Expire date',
    );
  }
}
