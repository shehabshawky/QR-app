class AnalyticsModel {
  final Timeframe timeframe;
  final String productId;
  final MonthData previousMonth;
  final MonthData currentMonth;
  final Changes changes;

  AnalyticsModel({
    required this.timeframe,
    required this.productId,
    required this.previousMonth,
    required this.currentMonth,
    required this.changes,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      timeframe: Timeframe.fromJson(json['timeframe']),
      productId: json['product_id'],
      previousMonth: MonthData.fromJson(json['previous_month']),
      currentMonth: MonthData.fromJson(json['current_month']),
      changes: Changes.fromJson(json['changes']),
    );
  }
}

class Timeframe {
  final DateRange previousMonth;
  final DateRange currentMonth;

  Timeframe({
    required this.previousMonth,
    required this.currentMonth,
  });

  factory Timeframe.fromJson(Map<String, dynamic> json) {
    return Timeframe(
      previousMonth: DateRange.fromJson(json['previous_month']),
      currentMonth: DateRange.fromJson(json['current_month']),
    );
  }
}

class DateRange {
  final String startDate;
  final String endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class MonthData {
  final int totalScans;
  final int totalRevenue;
  final int totalReports;
  final int revenueLost;

  MonthData({
    required this.totalScans,
    required this.totalRevenue,
    required this.totalReports,
    required this.revenueLost,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      totalScans: json['totalScans'],
      totalRevenue: json['totalRevenue'],
      totalReports: json['totalReports'],
      revenueLost: json['revenueLost'],
    );
  }
}

class Changes {
  final ChangeData totalScans;
  final ChangeData totalRevenue;
  final ChangeData totalReports;
  final ChangeData revenueLost;

  Changes({
    required this.totalScans,
    required this.totalRevenue,
    required this.totalReports,
    required this.revenueLost,
  });

  factory Changes.fromJson(Map<String, dynamic> json) {
    return Changes(
      totalScans: ChangeData.fromJson(json['totalScans']),
      totalRevenue: ChangeData.fromJson(json['totalRevenue']),
      totalReports: ChangeData.fromJson(json['totalReports']),
      revenueLost: ChangeData.fromJson(json['revenueLost']),
    );
  }
}

class ChangeData {
  final int value;
  final int percentage;

  ChangeData({
    required this.value,
    required this.percentage,
  });

  factory ChangeData.fromJson(Map<String, dynamic> json) {
    return ChangeData(
      value: json['value'],
      percentage: json['percentage'],
    );
  }
}
