import 'package:dhbwstudentapp/common/ui/viewmodels/base_view_model.dart';
import 'package:dhbwstudentapp/common/util/date_utils.dart';
import 'package:dhbwstudentapp/schedule/business/schedule_provider.dart';
import 'package:dhbwstudentapp/schedule/model/schedule.dart';

class DailyScheduleViewModel extends BaseViewModel {
  static const Duration weekDuration = Duration(days: 7);

  final ScheduleProvider scheduleProvider;

  final DateTime currentDate = DateTime.now().startOfDay;

  late Schedule _daySchedule;

  DailyScheduleViewModel(this.scheduleProvider) {
    scheduleProvider.addScheduleUpdatedCallback(_scheduleUpdatedCallback);

    _updateSchedule();
  }

  set schedule(Schedule schedule) {
    _daySchedule = schedule;
    notifyListeners("daySchedule");
  }

  Schedule get schedule => _daySchedule;

  Future<void> _updateSchedule() async {
    schedule = await scheduleProvider.getCachedSchedule(
      currentDate,
      currentDate.tomorrow,
    );
  }

  Future<void> _scheduleUpdatedCallback(
    Schedule schedule,
    DateTime start,
    DateTime end,
  ) async {
    final startDay = start.startOfDay;
    final endDay = end.tomorrow.startOfDay;

    if (!(startDay.isAfter(currentDate) || endDay.isBefore(currentDate))) {
      schedule.trim(
        currentDate.startOfDay,
        currentDate.tomorrow.startOfDay,
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
