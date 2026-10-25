abstract final class AppDate {
  static const List<String> weekdayNames = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> weekdayInitials = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime addDays(DateTime value, int days) =>
      DateTime(value.year, value.month, value.day + days);

  static String dateKey(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime? parseDateKey(String value) {
    try {
      final List<String> parts = value.split('-');
      if (parts.length != 3) {
        return null;
      }
      final int? year = int.tryParse(parts[0]);
      final int? month = int.tryParse(parts[1]);
      final int? day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) {
        return null;
      }
      final DateTime date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } on Object {
      return null;
    }
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Calendar-day distance, independent of daylight-saving transitions.
  static int daysBetween(DateTime from, DateTime to) {
    final DateTime start = DateTime.utc(from.year, from.month, from.day);
    final DateTime end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  static String formatLongDate(DateTime date) {
    return '${weekdayNames[date.weekday - 1]}, ${date.day} '
        '${monthNames[date.month - 1]} ${date.year}';
  }

  static String formatCompactDate(DateTime date) {
    return '${weekdayNames[date.weekday - 1]}, ${date.day} '
        '${monthNames[date.month - 1]}';
  }

  static String formatMonthYear(DateTime date) =>
      '${monthNames[date.month - 1]} ${date.year}';

  static String formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String formatDays(int days) => days == 1 ? '1 day' : '$days days';

  static String formatCoordinate(double value) =>
      '${value.abs().toStringAsFixed(4)}°${value >= 0 ? 'N' : 'S'}';

  static String formatLongitude(double value) =>
      '${value.abs().toStringAsFixed(4)}°${value >= 0 ? 'E' : 'W'}';

  static String formatCoordinates(double latitude, double longitude) {
    return '${formatCoordinate(latitude)}, ${formatLongitude(longitude)}';
  }
}
