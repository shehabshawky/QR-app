
class DateFormatter {
  static String formatDate(String date) {
    if (date.isEmpty) return '';
    
    try {
      final DateTime dateTime = DateTime.parse(date);
      final String month = _getMonthAbbreviation(dateTime.month);
      return '$month ${dateTime.day}';
    } catch (e) {
      return date;
    }
  }

  static String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static String formatPeriod(String period, [String? previousPeriod]) {
    try {
      // Parse the current period (format: "YYYY/MM")
      final parts = period.split('/');
      if (parts.length == 2) {
        final currentYear = parts[0];
        final currentMonth = int.tryParse(parts[1]);
        
        if (currentMonth != null) {
          final monthStr = _getMonthAbbreviation(currentMonth);
          // Always show year with month
          return '$monthStr\n$currentYear';
        }
      }
      return period;
    } catch (e) {
      print('Error formatting period: $e');
      return period;
    }
  }
} 