import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'date_formatter.dart';

class ChartUtils {
  static double parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double calculateMaxY(List<double> values) {
    if (values.isEmpty) return 10;
    final maxY = values.reduce((max, value) => max > value ? max : value);
    
    // For small values (0-10), use intervals of 1
    if (maxY <= 10) {
      return (((maxY + 4) ~/ 5) * 5).toDouble();
    }
    // For medium values (10-100), use intervals of 10
    else if (maxY <= 100) {
      return (((maxY + 9) ~/ 10) * 10).toDouble();
    }
    // For larger values (100-1000), use intervals of 50
    else if (maxY <= 1000) {
      return (((maxY + 49) ~/ 50) * 50).toDouble();
    }
    // For very large values (>1000), use intervals of 100
    else {
      return (((maxY + 99) ~/ 100) * 100).toDouble();
    }
  }

  static double getInterval(double maxY) {
    if (maxY <= 10) return 1.0;
    if (maxY <= 100) return 10.0;
    if (maxY <= 1000) return 50.0;
    return 100.0;
  }

  static TextStyle getCommonAxisTextStyle() {
    return const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 12,
    );
  }

  static FlGridData getCommonGridData({required double interval}) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color(0xFFE2E8F0),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  static FlBorderData getCommonBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300),
        left: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  /// Prepares chart data by filtering duplicates and formatting periods
  static Map<String, dynamic> prepareChartData(List<dynamic> rawData, String countKey) {
    if (rawData.isEmpty) {
      return {
        'uniqueData': <dynamic>[],
        'spots': <FlSpot>[],
        'periodLabels': <int, String>{},
        'maxY': 10.0,
      };
    }

    // Sort data by period first
    final sortedData = List<dynamic>.from(rawData)
      ..sort((a, b) => (a['period'] as String).compareTo(b['period'] as String));

    // Create spots and period labels
    final spots = <FlSpot>[];
    final periodLabels = <int, String>{};
    final uniqueData = <dynamic>[];

    // Process each data point in order
    for (int i = 0; i < sortedData.length; i++) {
      final item = sortedData[i];
      final count = parseCount(item[countKey]);
      
      uniqueData.add(item);
      spots.add(FlSpot(i.toDouble(), count));
      
      // Get previous period for date formatting
      final previousPeriod = i > 0 ? sortedData[i - 1]['period'] as String : null;
      periodLabels[i] = DateFormatter.formatPeriod(item['period'] as String, previousPeriod);
    }

    // Calculate maxY
    final maxY = calculateMaxY(spots.map((spot) => spot.y).toList());

    return {
      'uniqueData': uniqueData.asMap(),
      'spots': spots,
      'periodLabels': periodLabels,
      'maxY': maxY,
    };
  }

  /// Generates a list of all periods (YYYY/MM) between start and end periods
  static List<String> _generateAllPeriods(String startPeriod, String endPeriod) {
    final periods = <String>[];
    
    final startParts = startPeriod.split('/');
    final endParts = endPeriod.split('/');
    
    int startYear = int.parse(startParts[0]);
    int startMonth = int.parse(startParts[1]);
    int endYear = int.parse(endParts[0]);
    int endMonth = int.parse(endParts[1]);

    while (startYear < endYear || (startYear == endYear && startMonth <= endMonth)) {
      periods.add('$startYear/${startMonth.toString().padLeft(2, '0')}');
      
      startMonth++;
      if (startMonth > 12) {
        startMonth = 1;
        startYear++;
      }
    }

    return periods;
  }
} 