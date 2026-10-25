class MonthCell {
  const MonthCell(this.date);

  final DateTime? date;
}

class MonthGrid {
  MonthGrid._({
    required this.month,
    required this.leadingBlanks,
    required this.dayCount,
    required this.cells,
  });

  final DateTime month;
  final int leadingBlanks;
  final int dayCount;
  final List<MonthCell> cells;

  factory MonthGrid.forMonth(DateTime date) {
    final DateTime month = DateTime(date.year, date.month);
    final DateTime first = DateTime(month.year, month.month);
    final int dayCount = daysInMonth(month.year, month.month);
    final int leadingBlanks = (first.weekday - DateTime.monday) % 7;
    final int used = leadingBlanks + dayCount;
    final int totalCells = used % 7 == 0 ? used : used + (7 - used % 7);

    final List<MonthCell> cells = <MonthCell>[];
    for (int index = 0; index < totalCells; index++) {
      final int day = index - leadingBlanks + 1;
      cells.add(
        day >= 1 && day <= dayCount
            ? MonthCell(DateTime(month.year, month.month, day))
            : const MonthCell(null),
      );
    }

    return MonthGrid._(
      month: month,
      leadingBlanks: leadingBlanks,
      dayCount: dayCount,
      cells: cells,
    );
  }

  int get rowCount => cells.length ~/ 7;

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  DateTime get previousMonth => DateTime(month.year, month.month - 1);

  DateTime get nextMonth => DateTime(month.year, month.month + 1);

  bool isSameMonth(DateTime date) =>
      date.year == month.year && date.month == month.month;

  bool isCurrentMonth(DateTime today) => isSameMonth(today);
}
