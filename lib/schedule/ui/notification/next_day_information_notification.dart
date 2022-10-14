import 'package:dhbwstudentapp/common/background/task_callback.dart';
import 'package:dhbwstudentapp/common/background/work_scheduler_service.dart';
import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/common/ui/notification_api.dart';
import 'package:dhbwstudentapp/common/util/date_utils.dart';
import 'package:dhbwstudentapp/common/util/string_utils.dart';
import 'package:dhbwstudentapp/schedule/data/schedule_entry_repository.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_entry.dart';
import 'package:intl/intl.dart';

class NextDayInformationNotification extends TaskCallback {
  final PreferencesProvider _preferencesProvider;
  final NotificationApi _notificationApi;
  final ScheduleEntryRepository _scheduleEntryRepository;
  final WorkSchedulerService _scheduler;
  final L _localization;

  NextDayInformationNotification(
    this._notificationApi,
    this._scheduleEntryRepository,
    this._scheduler,
    this._localization,
    this._preferencesProvider,
  );

  @override
  Future<void> run() async {
    await schedule();

    if (!await _preferencesProvider.getNotifyAboutNextDay()) {
      return;
    }

    final now = DateTime.now();

    final nextScheduleEntry =
        await _scheduleEntryRepository.queryNextScheduleEntry(now);

    if (nextScheduleEntry == null) return;

    final format = DateFormat.Hm();
    final daysToNextEntry = toStartOfDay(nextScheduleEntry.start)!
        .difference(toStartOfDay(now)!)
        .inDays;

    if (daysToNextEntry > 1) return;

    final message = _getNotificationMessage(
      daysToNextEntry,
      nextScheduleEntry,
      format,
    );

    await _notificationApi.showNotification(
      _localization.notificationNextClassTitle,
      message,
    );
  }

  String? _getNotificationMessage(
      int daysToNextEntry, ScheduleEntry nextScheduleEntry, DateFormat format,) {
    switch (daysToNextEntry) {
      case 0:
        return interpolate(
          _localization.notificationNextClassNextClassAtMessage,
          [
            nextScheduleEntry.title,
            format.format(nextScheduleEntry.start),
          ],
        );

      case 1:
        return interpolate(
          _localization.notificationNextClassTomorrow,
          [
            nextScheduleEntry.title,
            format.format(nextScheduleEntry.start),
          ],
        );

      default:
        return null;
    }
  }

  @override
  Future<void> schedule() async {
    final nextSchedule = toTimeOfDayInFuture(DateTime.now(), 20, 00);
    await _scheduler.scheduleOneShotTaskAt(
      nextSchedule,
      "NextDayInformationNotification" + DateFormat.yMd().format(nextSchedule),
      "NextDayInformationNotification",
    );
  }

  @override
  Future<void> cancel() async {
    final nextSchedule = toTimeOfDayInFuture(DateTime.now(), 20, 00);
    await _scheduler.cancelTask(
      "NextDayInformationNotification" + DateFormat.yMd().format(nextSchedule),
    );
  }

  @override
  String getName() {
    return name;
  }

  static String get name => "NextDayInformationNotification";
}
