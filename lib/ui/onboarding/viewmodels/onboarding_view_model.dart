import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/common/ui/viewmodels/base_view_model.dart';
import 'package:dhbwstudentapp/ui/onboarding/onboardin_step.dart';

typedef OnboardingFinished = void Function();

class OnboardingViewModel extends BaseViewModel {
  final PreferencesProvider preferencesProvider;
  final OnboardingFinished _onboardingFinished;

  final List<String> steps = [
    "selectSource",
    "rapla",
    "dualis",
  ];

  final Map<String, OnboardingStep> pages = {
    "selectSource": SelectSourceOnboardingStep(),
    "rapla": RaplaOnboardingStep(),
    "dualis": DualisCredentialsOnboardingStep(),
  };

  final Map<String, int> stepsBackstack = {};

  int _stepIndex = 0;
  int get stepIndex => _stepIndex;

  String get currentStep => steps[_stepIndex];

  bool get currentPageValid => pages[currentStep].viewModel().isValid;
  bool get isLastStep => _stepIndex >= steps.length - 1;

  get onboardingSteps => steps.length;

  bool _didStepForward = true;
  bool get didStepForward => _didStepForward;

  OnboardingViewModel(
    this.preferencesProvider,
    this._onboardingFinished,
  ) {
    for (var page in pages.values) {
      page.viewModel().addListener(() {
        notifyListeners("currentPageValid");
      }, ["isValid"]);
    }
  }

  void previousPage() {
    var lastPage = stepsBackstack.keys.last;

    _stepIndex = stepsBackstack[lastPage];

    stepsBackstack.remove(lastPage);

    _didStepForward = false;

    notifyListeners();
  }

  void nextPage() {
    if (_stepIndex == steps.length - 1) {
      finishOnboarding();
      return;
    }

    var nextDesiredStep = pages[currentStep].nextStep();

    print("Next desired step: $nextDesiredStep");

    stepsBackstack[currentStep] = _stepIndex;

    if (nextDesiredStep == null) {
      nextDesiredStep = steps[_stepIndex + 1];
    }

    while (nextDesiredStep != currentStep) {
      _stepIndex++;
    }

    _didStepForward = true;

    notifyListeners();
  }

  void finishOnboarding() {
    for (var step in stepsBackstack.keys) {
      pages[step].viewModel().save();
    }

    _onboardingFinished?.call();
  }
}
