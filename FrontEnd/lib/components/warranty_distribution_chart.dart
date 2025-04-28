import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WarrantyDistributionChart extends StatelessWidget {
  final Map<String, dynamic> warrantyData;

  const WarrantyDistributionChart({
    super.key,
    required this.warrantyData,
  });

  @override
  Widget build(BuildContext context) {
    if (warrantyData.isEmpty) {
      return const Center(child: Text('No warranty data available'));
    }

    final List<PieChartSectionData> sections = [];
    
    // Get values from the API response
    final double activeCount = (warrantyData['activeCount'] as num?)?.toDouble() ?? 0.0;
    final double expiredCount = (warrantyData['expiredCount'] as num?)?.toDouble() ?? 0.0;
    final double totalCount = (warrantyData['totalCount'] as num?)?.toDouble() ?? 0.0;
    final double activePercentage = (warrantyData['activePercentage'] as num?)?.toDouble() ?? 0.0;
    final double expiredPercentage = (warrantyData['expiredPercentage'] as num?)?.toDouble() ?? 0.0;

    if (totalCount == 0) {
      return const Center(child: Text('No valid warranty data available'));
    }

    // Define colors
    const activeColor = Color(0xFF7EBCB9);  // Teal
    const expiredColor = Color(0xFFFF9E9E);  // Coral pink

    sections.addAll([
      PieChartSectionData(
        color: activeColor,
        value: activeCount,
        title: '${activeCount.toInt()}\n${activePercentage.toStringAsFixed(2)}%',
        radius: 90,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
        titlePositionPercentageOffset: 0.55,
        showTitle: true,
      ),
      PieChartSectionData(
        color: expiredColor,
        value: expiredCount,
        title: '${expiredCount.toInt()}\n${expiredPercentage.toStringAsFixed(2)}%',
        radius: 90,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
        titlePositionPercentageOffset: 0.55,
        showTitle: true,
      ),
    ]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Warranty Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 28),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 45,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            // Center text showing total
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalCount.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Expired', expiredColor),
            const SizedBox(width: 24),
            _buildLegendItem('Active Warranty', activeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }
} 