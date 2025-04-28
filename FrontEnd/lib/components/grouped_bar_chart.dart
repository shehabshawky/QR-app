import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/chart_utils.dart';

class GroupedBarChart extends StatelessWidget {
  final List<dynamic> data;
  final String title;
  final String labelKey;
  final String firstCountKey;
  final String secondCountKey;
  final String totalCountKey;
  final String firstLegendLabel;
  final String secondLegendLabel;
  final Color firstColor;
  final Color secondColor;

  const GroupedBarChart({
    super.key,
    required this.data,
    required this.title,
    required this.labelKey,
    required this.firstCountKey,
    required this.secondCountKey,
    required this.totalCountKey,
    required this.firstLegendLabel,
    required this.secondLegendLabel,
    this.firstColor = const Color(0xFF818CF8),
    this.secondColor = const Color(0xFF94F1E9),
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No $title data available'));
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    try {
      barGroups = data.asMap().entries.map((entry) {
        final item = entry.value as Map<String, dynamic>? ?? {};
        final totalCount = ChartUtils.parseCount(item[totalCountKey]);
        final firstCount = ChartUtils.parseCount(item[firstCountKey]);
        final secondCount = ChartUtils.parseCount(item[secondCountKey]);
        
        // Update maxY for scaling
        maxY = maxY < totalCount ? totalCount : maxY;
        
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: firstCount.toDouble(),
              color: firstColor,
              width: 12, // Reduced width
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: secondCount.toDouble(),
              color: secondColor,
              width: 12, // Reduced width
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
          barsSpace: 4, // Add space between bars in the same group
        );
      }).toList();
    } catch (e) {
      print('Error creating bars: $e');
      return Center(child: Text('Error processing $title data'));
    }

    if (barGroups.isEmpty) {
      return Center(child: Text('No valid $title data available'));
    }

    // Round up maxY to nearest multiple of 2 for small values, or 20 for larger values
    if (maxY <= 10) {
      maxY = (((maxY + 1) ~/ 2) * 2).toDouble();
      // Add small padding for small values
      maxY += 1;
    } else {
      maxY = (((maxY + 19) ~/ 20) * 20).toDouble();
      // Add 10% padding for larger values
      maxY *= 1.1;
    }

    // Calculate interval based on maxY
    final interval = maxY <= 10 ? 1.0 : 20.0;
    final axisTextStyle = ChartUtils.getCommonAxisTextStyle();

    return Container(
      height: 400,
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16), // Add padding for long labels
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: interval,
                    verticalInterval: 0.5, // Adjusted for better spacing
                    checkToShowVerticalLine: (value) {
                      // Only show lines at whole number positions (between bars)
                      return value.toInt() == value;
                    },
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFE2E8F0),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFE2E8F0),
                        strokeWidth: 1.5, // Slightly thicker for better visibility
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final item = data[value.toInt()] as Map<String, dynamic>? ?? {};
                          final label = item[labelKey] as String? ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                label,
                                style: axisTextStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                        reservedSize: 100, // Increased space for labels
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0 || value < 0) return const SizedBox.shrink();
                          if (value > maxY) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: axisTextStyle,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  barGroups: barGroups,
                  minY: 0,
                  maxY: maxY,
                  groupsSpace: 32,
                  alignment: BarChartAlignment.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: firstColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                firstLegendLabel,
                style: axisTextStyle,
              ),
              const SizedBox(width: 24),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: secondColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                secondLegendLabel,
                style: axisTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 