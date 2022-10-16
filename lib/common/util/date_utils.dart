extension DateTimeExtension on DateTime {
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  DateTime get tomorrow {
    return addDays(1);
  }

  DateTime addDays(int days) {
    return DateTime(
      year,
      month,
      day + days,
      hour,
      minute,
      second,
    );
  }

  DateTime get monday {
    return subtract(Duration(days: weekday - 1));
  }

  DateTime get previousWeek {
    return DateTime(
      year,
      month,
      day - 7,
      hour,
      minute,
      second,
    );
  }

  DateTime get nextWeek {
    return DateTime(
      year,
      month,
      day + 7,
      hour,
      minute,
      second,
    );
  }

  DateTime get nextMonth {
    return DateTime(
      year,
      month + 1,
      day,
      hour,
      minute,
      second,
    );
  }

  DateTime toTimeOfDay(int hour, int minute) {
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );
  }

  DateTime toTimeOfDayInFuture(int hour, int minute) {
    final newDateTime = DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );

    if (isAfter(newDateTime)) return newDateTime.tomorrow;

    return newDateTime;
  }

  bool isAtSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime toDayOfWeek(int weekday) {
    return addDays(-weekday).addDays(weekday);
  }

  bool get isAtMidnight {
    return hour == 0 && minute == 0;
  }
}
