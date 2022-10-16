import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_entry.dart';
import 'package:flutter/material.dart';

typedef ColorDelegate = Color Function(BuildContext context);
typedef TextDelegate = String Function(BuildContext context);

final Map<ScheduleEntryType, TextDelegate> scheduleEntryTypeTextMapping = {
  ScheduleEntryType.publicHoliday: (c) =>
      L.of(c).scheduleEntryTypePublicHoliday,
  ScheduleEntryType.lesson: (c) => L.of(c).scheduleEntryTypeClass,
  ScheduleEntryType.exam: (c) => L.of(c).scheduleEntryTypeExam,
  ScheduleEntryType.online: (c) => L.of(c).scheduleEntryTypeOnline,
  ScheduleEntryType.unknown: (c) => L.of(c).scheduleEntryTypeUnknown,
};

String scheduleEntryTypeToReadableString(
  BuildContext context,
  ScheduleEntryType type,
) {
  return scheduleEntryTypeTextMapping[type]!(context);
}
