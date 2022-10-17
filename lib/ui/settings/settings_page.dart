import 'package:dhbwstudentapp/assets.dart';
import 'package:dhbwstudentapp/common/application_constants.dart';
import 'package:dhbwstudentapp/common/background/task_callback.dart';
import 'package:dhbwstudentapp/common/background/work_scheduler_service.dart';
import 'package:dhbwstudentapp/common/data/preferences/preferences_provider.dart';
import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:dhbwstudentapp/common/ui/viewmodels/root_view_model.dart';
import 'package:dhbwstudentapp/common/ui/widgets/title_list_tile.dart';
import 'package:dhbwstudentapp/date_management/data/calendar_access.dart';
import 'package:dhbwstudentapp/date_management/model/date_entry.dart';
import 'package:dhbwstudentapp/date_management/ui/calendar_export_page.dart';
import 'package:dhbwstudentapp/schedule/background/calendar_synchronizer.dart';
import 'package:dhbwstudentapp/schedule/ui/notification/next_day_information_notification.dart';
import 'package:dhbwstudentapp/schedule/ui/widgets/select_source_dialog.dart';
import 'package:dhbwstudentapp/ui/navigation/navigator_key.dart';
import 'package:dhbwstudentapp/ui/settings/donate_list_tile.dart';
import 'package:dhbwstudentapp/ui/settings/purchase_widget_list_tile.dart';
import 'package:dhbwstudentapp/ui/settings/select_theme_dialog.dart';
import 'package:dhbwstudentapp/ui/settings/viewmodels/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Cleanup ui generation code for the in app purchases
// TODO: Show a loading indicator and error messages right when the purchase button was pressed

///
/// Widget for the application settings route. Provides access to many settings
/// of the app
///
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsViewModel settingsViewModel = SettingsViewModel(
    KiwiContainer().resolve(),
    KiwiContainer()
            .resolve<TaskCallback>(NextDayInformationNotification.nameProp)
        as NextDayInformationNotification,
    KiwiContainer().resolve(),
    KiwiContainer().resolve(),
  );

  _SettingsPageState();

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      ...buildScheduleSourceSettings(),
      ...buildDesignSettings(),
      ...buildNotificationSettings(),
      ...buildAboutSettings(),
      buildDisclaimer(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actionsIconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(L.of(context).settingsPageTitle),
        toolbarTextStyle: Theme.of(context).textTheme.bodyText2,
        titleTextStyle: Theme.of(context).textTheme.headline6,
      ),
      body: PropertyChangeProvider<SettingsViewModel, String>(
        value: settingsViewModel,
        child: ListView(
          children: widgets,
        ),
      ),
    );
  }

  Widget buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        L.of(context).disclaimer,
        style: Theme.of(context).textTheme.overline,
      ),
    );
  }

  List<Widget> buildAboutSettings() {
    return [
      TitleListTile(title: L.of(context).settingsAboutTitle),
      const PurchaseWidgetListTile(),
      const DonateListTile(),
      ListTile(
        title: Text(L.of(context).settingsAbout),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationIcon: Image.asset(
              Assets.assets_app_icon_png,
              width: 75,
            ),
            applicationLegalese: L.of(context).applicationLegalese,
            applicationName: L.of(context).applicationName,
            applicationVersion: applicationVersion,
          );
        },
      ),
      ListTile(
        title: Text(L.of(context).settingsViewSourceCode),
        onTap: () {
          launchUrl(Uri.parse(applicationSourceCodeUrl));
        },
      ),
      const Divider(),
    ];
  }

  List<Widget> buildScheduleSourceSettings() {
    return [
      TitleListTile(title: L.of(context).settingsScheduleSourceTitle),
      ListTile(
        title: Text(L.of(context).settingsSetupScheduleSource),
        onTap: () async {
          await SelectSourceDialog(
            KiwiContainer().resolve(),
            KiwiContainer().resolve(),
          ).show(context);
        },
      ),
      PropertyChangeConsumer(
        properties: const [
          "prettifySchedule",
        ],
        builder:
            (BuildContext context, SettingsViewModel? model, Set? properties) {
          return SwitchListTile(
            title: Text(L.of(context).settingsPrettifySchedule),
            onChanged: model!.setPrettifySchedule,
            value: model.prettifySchedule,
          );
        },
      ),
      ListTile(
        title: Text(L.of(context).settingsCalendarSync),
        onTap: requestCalendarPermission,
      ),
      const Divider(),
    ];
  }

  List<Widget> buildNotificationSettings() {
    final WorkSchedulerService service = KiwiContainer().resolve();
    if (service.isSchedulingAvailable()) {
      return [
        TitleListTile(title: L.of(context).settingsNotificationsTitle),
        PropertyChangeConsumer(
          properties: const [
            "notifyAboutNextDay",
          ],
          builder: (
            BuildContext context,
            SettingsViewModel? model,
            Set? properties,
          ) {
            return SwitchListTile(
              title: Text(L.of(context).settingsNotificationsNextDay),
              onChanged: model!.setNotifyAboutNextDay,
              value: model.notifyAboutNextDay,
            );
          },
        ),
        PropertyChangeConsumer(
          properties: const [
            "notifyAboutScheduleChanges",
          ],
          builder: (
            BuildContext context,
            SettingsViewModel? model,
            Set? properties,
          ) {
            return SwitchListTile(
              title: Text(L.of(context).settingsNotificationsScheduleChange),
              onChanged: model!.setNotifyAboutScheduleChanges,
              value: model.notifyAboutScheduleChanges,
            );
          },
        ),
        const Divider(),
      ];
    } else {
      return [];
    }
  }

  List<Widget> buildDesignSettings() {
    return [
      TitleListTile(title: L.of(context).settingsDesign),
      PropertyChangeConsumer(
        properties: const [
          "appTheme",
        ],
        builder: (BuildContext context, RootViewModel? model, Set? properties) {
          return ListTile(
            title: Text(L.of(context).settingsDarkMode),
            onTap: () async {
              await SelectThemeDialog(model!).show(context);
            },
            subtitle: Text(
              {
                ThemeMode.dark: L.of(context).selectThemeDark,
                ThemeMode.light: L.of(context).selectThemeLight,
                ThemeMode.system: L.of(context).selectThemeSystem,
              }[model!.appTheme]!,
            ),
          );
        },
      ),
      const Divider(),
    ];
  }

  Future<void> requestCalendarPermission() async {
    final permission = await CalendarAccess().requestCalendarPermission();
    if (permission == CalendarPermission.denied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            L.of(context).dialogTitleCalendarAccessNotGranted,
          ),
          content: Text(L.of(context).dialogCalendarAccessNotGranted),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(L.of(context).dialogOk),
            )
          ],
        ),
      );
      return;
    }
    final isCalendarSyncEnabled = await KiwiContainer()
        .resolve<PreferencesProvider>()
        .isCalendarSyncEnabled();
    final List<DateEntry> entriesToExport =
        KiwiContainer().resolve<ListDateEntries30d>().listDateEntries;
    await NavigatorKey.rootKey.currentState!.push(
      MaterialPageRoute(
        builder: (BuildContext context) => CalendarExportPage(
          entriesToExport: entriesToExport,
          isCalendarSyncWidget: true,
          isCalendarSyncEnabled: isCalendarSyncEnabled,
        ),
        settings: const RouteSettings(name: "settings"),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    settingsViewModel.dispose();
  }
}
