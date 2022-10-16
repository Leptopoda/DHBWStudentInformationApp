import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_source_type.dart';
import 'package:dhbwstudentapp/ui/onboarding/viewmodels/onboarding_view_model_base.dart';

class SelectSourceViewModel extends OnboardingStepViewModel {
  final PreferencesProvider _preferencesProvider;

  ScheduleSourceType _scheduleSourceType = ScheduleSourceType.rapla;
  ScheduleSourceType get scheduleSourceType => _scheduleSourceType;

  SelectSourceViewModel(this._preferencesProvider) {
    isValid = true;
  }

  void setScheduleSourceType(ScheduleSourceType? type) {
    if (type == null) return;

    _scheduleSourceType = type;
    isValid = true;

    notifyListeners("scheduleSourceType");
  }

  @override
  Future<void> save() async {
    await _preferencesProvider.setScheduleSourceType(scheduleSourceType);
  }

  String? nextStep() {
    switch (_scheduleSourceType) {
      case ScheduleSourceType.rapla:
        return "rapla";
      case ScheduleSourceType.dualis:
        return "dualis";
      case ScheduleSourceType.none:
        return "dualis";
      case ScheduleSourceType.mannheim:
        return "mannheim";
      case ScheduleSourceType.ical:
        return "ical";
      default:
        return null;
    }
  }
}
