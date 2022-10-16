import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/schedule/business/schedule_source_provider.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_source_type.dart';
import 'package:dhbwstudentapp/schedule/ui/widgets/enter_dualis_credentials_dialog.dart';
import 'package:dhbwstudentapp/schedule/ui/widgets/enter_ical_url.dart';
import 'package:dhbwstudentapp/schedule/ui/widgets/enter_rapla_url_dialog.dart';
import 'package:dhbwstudentapp/schedule/ui/widgets/select_mannheim_course_dialog.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';

class SelectSourceDialog {
  final PreferencesProvider _preferencesProvider;
  final ScheduleSourceProvider _scheduleSourceProvider;

  ScheduleSourceType? _currentScheduleSource;

  SelectSourceDialog(this._preferencesProvider, this._scheduleSourceProvider);

  Future show(BuildContext context) async {
    _currentScheduleSource = await _preferencesProvider.getScheduleSourceType();

    await showDialog(
      context: context,
      builder: _buildDialog,
    );
  }

  SimpleDialog _buildDialog(BuildContext context) {
    return SimpleDialog(
      title: Text(L.of(context).onboardingScheduleSourceTitle),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            L.of(context).onboardingScheduleSourceDescription,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        RadioListTile<ScheduleSourceType>(
          groupValue: _currentScheduleSource,
          value: ScheduleSourceType.rapla,
          onChanged: (v) => sourceSelected(v, context),
          title: Text(L.of(context).scheduleSourceTypeRapla),
        ),
        RadioListTile<ScheduleSourceType>(
          groupValue: _currentScheduleSource,
          value: ScheduleSourceType.dualis,
          onChanged: (v) => sourceSelected(v, context),
          title: Text(L.of(context).scheduleSourceTypeDualis),
        ),
        RadioListTile<ScheduleSourceType>(
          groupValue: _currentScheduleSource,
          value: ScheduleSourceType.mannheim,
          onChanged: (v) => sourceSelected(v, context),
          title: Text(L.of(context).scheduleSourceTypeMannheim),
        ),
        RadioListTile<ScheduleSourceType>(
          groupValue: _currentScheduleSource,
          value: ScheduleSourceType.ical,
          onChanged: (v) => sourceSelected(v, context),
          title: Text(L.of(context).scheduleSourceTypeIcal),
        ),
        RadioListTile<ScheduleSourceType>(
          groupValue: _currentScheduleSource,
          value: ScheduleSourceType.none,
          onChanged: (v) => sourceSelected(v, context),
          title: Text(L.of(context).scheduleSourceTypeNone),
        )
      ],
    );
  }

  Future<void> sourceSelected(
    ScheduleSourceType? type,
    BuildContext context,
  ) async {
    if (type == null) return;
    // TODO: [Leptopoda] only switch the type when the setup is completed.
    _preferencesProvider.setScheduleSourceType(type);

    Navigator.of(context).pop();

    switch (type) {
      case ScheduleSourceType.none:
        await _scheduleSourceProvider.setupScheduleSource();
        break;
      case ScheduleSourceType.rapla:
        await EnterRaplaUrlDialog(
          _preferencesProvider,
          KiwiContainer().resolve(),
        ).show(context);
        break;
      case ScheduleSourceType.dualis:
        await EnterDualisCredentialsDialog(
          _preferencesProvider,
          KiwiContainer().resolve(),
        ).show(context);
        break;
      case ScheduleSourceType.ical:
        await EnterIcalDialog(
          _preferencesProvider,
          KiwiContainer().resolve(),
        ).show(context);
        break;
      case ScheduleSourceType.mannheim:
        await SelectMannheimCourseDialog(
          KiwiContainer().resolve(),
        ).show(context);
        break;
    }
  }
}
