// TODO: [Leptopoda] write extension methods directly on [DateTime]

DateTime? toStartOfDay(DateTime? dateTime) {
  return dateTime == null
      ? null
      : DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime? toStartOfMonth(DateTime? dateTime) {
  return dateTime == null
      ? null
      : DateTime(dateTime.year, dateTime.month);
}

DateTime? tomorrow(DateTime? dateTime) {
  return addDays(dateTime, 1);
}

DateTime? addDays(DateTime? dateTime, int days) {
  return dateTime == null
      ? null
      : DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day + days,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );
}

DateTime toMonday(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 1));
}

DateTime? toPreviousWeek(DateTime? dateTime) {
  return dateTime == null
      ? null
      : DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day - 7,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );
}

DateTime? toNextWeek(DateTime? dateTime) {
  return dateTime == null
      ? null
      : DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day + 7,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );
}

DateTime toNextMonth(DateTime dateTime) {
  return DateTime(
    dateTime.year,
    dateTime.month + 1,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
  );
}

DateTime toTimeOfDay(DateTime dateTime, int hour, int minute) {
  return DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    hour,
    minute,
  );
}

DateTime toTimeOfDayInFuture(DateTime dateTime, int hour, int minute) {
  var newDateTime = DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    hour,
    minute,
  );

  if (dateTime.isAfter(newDateTime)) newDateTime = tomorrow(newDateTime)!;

  return newDateTime;
}

bool isAtSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

DateTime? toDayOfWeek(DateTime? dateTime, int weekday) {
  if (dateTime == null) return null;

  var startOfWeek = addDays(dateTime, -dateTime.weekday);
  return addDays(startOfWeek, weekday);
}

bool isAtMidnight(DateTime dateTime) {
  return dateTime.hour == 0 && dateTime.minute == 0;
}
