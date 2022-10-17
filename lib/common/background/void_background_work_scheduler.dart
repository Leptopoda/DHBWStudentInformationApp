import 'package:dhbwstudentapp/common/background/task_callback.dart';
import 'package:dhbwstudentapp/common/background/work_scheduler_service.dart';

///
/// BackgroundScheduler implementation which does not do anything.
///
class VoidBackgroundWorkScheduler extends WorkSchedulerService {
  VoidBackgroundWorkScheduler() {
    print("Background scheduling is not available!");
  }

  @override
  Future<void> scheduleOneShotTaskIn(
    Duration delay,
    String id,
    String name,
  ) async {
    print(
      "Did not schedule one shot task: $id. With a delay of ${delay.inMinutes} minutes.",
    );
  }

  @override
  Future<void> scheduleOneShotTaskAt(
    DateTime date,
    String id,
    String name,
  ) async {
    await scheduleOneShotTaskIn(date.difference(DateTime.now()), id, name);
  }

  @override
  Future<void> cancelTask(String id) async {
    print("Cancelled task $id");
  }

  @override
  Future<void> schedulePeriodic(
    Duration delay,
    String id, [
    bool needsNetwork = false,
  ]) async {
    print(
      "Did not schedule periodic task: $id. With a delay of ${delay.inMinutes} minutes. Requires network: $needsNetwork",
    );
  }

  @override
  void registerTask(TaskCallback task) {}

  @override
  Future<void> executeTask(String id) async {}

  @override
  bool isSchedulingAvailable() {
    return false;
  }
}
