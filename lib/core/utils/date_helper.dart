/// Statistics period selector — Weekly / Monthly / Yearly.
enum StatsPeriod { week, month, year }

/// Small date helpers used for grouping and period filtering.
///
/// Kept out of the Cubit body to keep business logic readable and
/// out of widgets entirely, per the architecture rule.
class DateHelper {
  DateHelper._();

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Start of the range for [period], inclusive, relative to now.
  static DateTime startOf(StatsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.week:
        final weekday = now.weekday; // 1 = Monday
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
      case StatsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case StatsPeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }

  static bool isWithinPeriod(DateTime date, StatsPeriod period) {
    final start = startOf(period);
    final end = DateTime.now().add(const Duration(days: 1));
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end);
  }
}