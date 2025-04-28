import 'package:flutter/material.dart';
import 'grouped_bar_chart.dart';

class ProductCategoriesChart extends StatelessWidget {
  final List<dynamic> categoryData;

  const ProductCategoriesChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    // Transform the data to include originalCount
    final transformedData = categoryData.map((item) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(item);
      final int scansCount = (data['scansCount'] as num?)?.toInt() ?? 0;
      final int counterfeitCount = (data['counterfeitCount'] as num?)?.toInt() ?? 0;
      data['originalCount'] = scansCount - counterfeitCount;
      return data;
    }).toList();

    return GroupedBarChart(
      data: transformedData,
      title: 'Product Categories',
      labelKey: 'category',
      firstCountKey: 'counterfeitCount',
      secondCountKey: 'originalCount',
      totalCountKey: 'scansCount',
      firstLegendLabel: 'Counterfeit',
      secondLegendLabel: 'Original',
      firstColor: const Color(0xFF818CF8),  // Purple for counterfeit
      secondColor: const Color(0xFF94F1E9),  // Teal for original
    );
  }
} 