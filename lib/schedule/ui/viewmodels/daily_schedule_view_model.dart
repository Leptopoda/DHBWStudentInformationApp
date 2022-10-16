import 'package:dhbwstudentapp/common/ui/viewmodels/base_view_model.dart';
import 'package:dhbwstudentapp/common/util/date_utils.dart';
import 'package:dhbwstudentapp/schedule/business/schedule_provider.dart';
import 'package:dhbwstudentapp/schedule/model/schedule.dart';

class DailyScheduleViewModel extends BaseViewModel {
  static const Duration weekDuration = Duration(days: 7);

  final ScheduleProvider scheduleProvider;

  DateTime? currentDate;

  Schedule? _daySchedule;

  DailyScheduleViewModel(this.scheduleProvider) {
    scheduleProvider.addScheduleUpdatedCallback(_scheduleUpdatedCallback);

    loadScheduleForToday();
  }

  set schedule(Schedule schedule) {
    _daySchedule = schedule;
    notifyListeners("daySchedule");
  }

  Schedule get schedule => _daySchedule ??= const Schedule();

  Future loadScheduleForToday() async {
    currentDate = DateTime.now().startOfDay;

    await updateSchedule();
  }

  Future updateSchedule() async {
    await _updateScheduleFromCache();
  }

  Future _updateScheduleFromCache() async {
    schedule = await scheduleProvider.getCachedSchedule(
      currentDate!,
      currentDate!.tomorrow,
    );
  }

  Future<void> _scheduleUpdatedCallback(
    Schedule schedule,
    DateTime start,
    DateTime end,
  ) async {
    final startDay = start.startOfDay;
    final endDay = end.tomorrow.startOfDay;

    if (!(startDay.isAfter(currentDate!) || endDay.isBefore(currentDate!))) {
      schedule.trim(
        currentDate?.startOfDay,
        currentDate?.tomorrow.startOfDay,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    scheduleProvider.removeScheduleUpdatedCallback(
      _scheduleUpdatedCallback,
    );
  }
}
