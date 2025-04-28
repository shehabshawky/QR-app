import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/chart_utils.dart';
import '../utils/date_formatter.dart';

enum ChartType { line, bar }

class GroupedIntervalChart extends StatelessWidget {
  final List<dynamic> activityData;
  final String title;
  final String countKey;
  final Color chartColor;
  final bool showCurrency;
  final ChartType chartType;
  final String? legendLabel;

  const GroupedIntervalChart({
    super.key,
    required this.activityData,
    required this.title,
    required this.countKey,
    required this.chartColor,
    this.showCurrency = false,
    this.chartType = ChartType.line,
    this.legendLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (activityData.isEmpty) {
      return Center(child: Text('No $title data available'));
    }

    // Sort the raw data by period
    final sortedData = List<dynamic>.from(activityData)
      ..sort(
          (a, b) => (a['period'] as String).compareTo(b['period'] as String));

    // Create spots directly from sorted data
    final spots = sortedData.asMap().entries.map((entry) {
      final count = ChartUtils.parseCount(entry.value[countKey]);
      return FlSpot(entry.key.toDouble(), count);
    }).toList();

    // Create period labels
    final periodLabels = sortedData.asMap().map((key, value) => MapEntry(
        key,
        DateFormatter.formatPeriod(value['period'] as String,
            key > 0 ? sortedData[key - 1]['period'] as String : null)));

    // Calculate maxY
    final maxY = spots.isEmpty
        ? 10.0
        : ChartUtils.calculateMaxY(spots.map((spot) => spot.y).toList());

    if (spots.isEmpty) {
      return Center(child: Text('No valid $title data available'));
    }

    final interval = ChartUtils.getInterval(maxY);
    final axisTextStyle = ChartUtils.getCommonAxisTextStyle();

    final bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 100,
        interval: 1,
        getTitlesWidget: (value, meta) {
          if (value < 0 || value >= sortedData.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                periodLabels[value.toInt()] ?? '',
                style: axisTextStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );

    return Container(
      height: 600,
      padding: const EdgeInsets.fromLTRB(0, 16, 34, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartType == ChartType.line
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        verticalInterval: 1,
                        checkToShowVerticalLine: (value) => true,
                        horizontalInterval: interval,
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
                            strokeWidth: 1,
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
                        bottomTitles: bottomTitles,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0 || value < 0) {
                                return const SizedBox.shrink();
                              }
                              if (value > maxY) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  showCurrency
                                      ? 'EGP ${value.toInt()}'
                                      : value.toInt().toString(),
                                  style: axisTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                            reservedSize: 65,
                          ),
                        ),
                      ),
                      borderData: ChartUtils.getCommonBorderData(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          color: chartColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: chartColor,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: chartColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                      maxX: (spots.length - 1).toDouble(),
                      minX: 0,
                      maxY: maxY,
                      minY: 0,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toInt()}',
                                TextStyle(color: chartColor),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData:
                          ChartUtils.getCommonGridData(interval: interval),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: bottomTitles,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0 || value < 0) {
                                return const SizedBox.shrink();
                              }
                              if (value > maxY) return const SizedBox.shrink();
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 8, left: 0),
                                child: Text(
                                  showCurrency
                                      ? 'EGP ${value.toInt()}'
                                      : value.toInt().toString(),
                                  style: axisTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                            reservedSize: 65,
                          ),
                        ),
                      ),
                      borderData: ChartUtils.getCommonBorderData(),
                      barGroups: sortedData.asMap().entries.map((entry) {
                        final data = entry.value as Map<String, dynamic>? ?? {};
                        final count = ChartUtils.parseCount(data[countKey]);
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: count,
                              color: chartColor,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                      minY: 0,
                      maxY: maxY,
                      groupsSpace: 12,
                      alignment: BarChartAlignment.center,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          if (legendLabel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chartColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  legendLabel!,
                  style: axisTextStyle,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
