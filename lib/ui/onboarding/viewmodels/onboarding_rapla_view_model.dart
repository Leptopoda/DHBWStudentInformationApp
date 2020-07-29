import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/common/ui/viewmodels/base_view_model.dart';
import 'package:dhbwstudentapp/schedule/service/rapla/rapla_schedule_source.dart';
import 'package:dhbwstudentapp/ui/onboarding/viewmodels/onboarding_view_model_base.dart';
import 'package:flutter/services.dart';

class OnboardingRaplaViewModel extends OnboardingViewModelBase {
  final PreferencesProvider preferencesProvider;

  String _raplaUrl;
  String get raplaUrl => _raplaUrl;

  bool urlHasError = false;

  OnboardingRaplaViewModel(this.preferencesProvider);

  void setRaplaUrl(String url) {
    _raplaUrl = url;

    notifyListeners("raplaUrl");

    validateUrl();
  }

  void validateUrl() {
    try {
      new RaplaScheduleSource().validateEndpointUrl(_raplaUrl);
      urlHasError = false;
    } catch (e) {
      urlHasError = true;
    }

    setIsValid(!urlHasError);

    notifyListeners("urlHasError");
  }

  Future<void> pasteUrl() async {
    ClipboardData data = await Clipboard.getData('text/plain');

    if (data?.text != null) {
      setRaplaUrl(data.text);
    }
  }

  @override
  Future<void> save() async {
    await preferencesProvider.setRaplaUrl(_raplaUrl);
  }
}
