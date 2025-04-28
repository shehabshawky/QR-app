import 'package:flutter/material.dart';
import 'grouped_bar_chart.dart';

class GeographicDistributionChart extends StatelessWidget {
  final List<dynamic> distributionData;

  const GeographicDistributionChart({
    super.key,
    required this.distributionData,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedBarChart(
      data: distributionData,
      title: 'Geographical Distribution',
      labelKey: 'location',
      firstCountKey: 'counterfeitCount',
      secondCountKey: 'scansCount',
      totalCountKey: 'scansCount',
      firstLegendLabel: 'Counterfeit',
      secondLegendLabel: 'Original',
    );
  }
} 