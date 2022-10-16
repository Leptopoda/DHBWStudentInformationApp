import 'package:device_calendar/device_calendar.dart';
import 'package:dhbwstudentapp/common/application_constants.dart';
import 'package:dhbwstudentapp/common/data/preferences/preferences_access.dart';
import 'package:dhbwstudentapp/common/data/preferences/secure_storage_access.dart';
import 'package:dhbwstudentapp/date_management/data/calendar_access.dart';
import 'package:dhbwstudentapp/dualis/model/credentials.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_source_type.dart';
import 'package:flutter/material.dart';

class PreferencesProvider {
  static const String appThemeKey = "AppTheme";
  static const String raplaUrlKey = "RaplaUrl";
  static const String isFirstStartKey = "IsFirstStart";
  static const String lastUsedLanguageCode = "LastUsedLanguageCode";
  static const String notifyAboutNextDay = "NotifyAboutNextDay";
  static const String notifyAboutScheduleChanges = "NotifyAboutScheduleChanges";
  static const String rateInStoreLaunchCountdown = "RateInStoreLaunchCountdown";
  static const String dontShowRateNowDialog = "RateNeverButtonPressed";
  static const String dualisStoreCredentials = "StoreDualisCredentials";
  static const String dualisUsername = "DualisUsername";
  static const String dualisPassword = "DualisPassword";
  static const String lastViewedSemester = "LastViewedSemester";
  static const String lastViewedDateEntryDatabase =
      "LastViewedDateEntryDatabase";
  static const String lastViewedDateEntryYear = "LastViewedDateEntryYear";
  static const String scheduleSourceType = "ScheduleSourceType";
  static const String scheduleIcalUrl = "ScheduleIcalUrl";
  static const String mannheimScheduleId = "MannheimScheduleId";
  static const String prettifySchedule = "PrettifySchedule";
  static const String didShowWidgetHelpDialog = "DidShowWidgetHelpDialog";
  static const String synchronizeScheduleWithCalendar =
      "SynchronizeScheduleWithCalendar";

  final PreferencesAccess _preferencesAccess;
  final SecureStorageAccess _secureStorageAccess;

  const PreferencesProvider(this._preferencesAccess, this._secureStorageAccess);

  Future<ThemeMode> appTheme() async {
    final theme = await _preferencesAccess.get<String>(appThemeKey);
    final themeName = theme?.toLowerCase();

    return ThemeMode.values.firstWhere(
      (element) => element.name == themeName,
      orElse: () {
        return ThemeMode.system;
      },
    );
  }

  Future<void> setAppTheme(ThemeMode value) async {
    await _preferencesAccess.set<String>(appThemeKey, value.name);
  }

  Future<void> setIsCalendarSyncEnabled(bool value) async {
    await _preferencesAccess.set<bool>('isCalendarSyncEnabled', value);
  }

  Future<bool> isCalendarSyncEnabled() async {
    return await _preferencesAccess.get<bool>('isCalendarSyncEnabled') ?? false;
  }

  Future<void> setSelectedCalendar(Calendar? selectedCalendar) async {
    final selectedCalendarId = selectedCalendar?.id ?? "";
    await _preferencesAccess.set<String>(
      'SelectedCalendarId',
      selectedCalendarId,
    );
  }

  Future<Calendar?> getSelectedCalendar() async {
    Calendar? selectedCalendar;
    final String? selectedCalendarId =
        await _preferencesAccess.get<String>('SelectedCalendarId');
    final List<Calendar>? availableCalendars =
        await CalendarAccess().queryWriteableCalendars();
    if (selectedCalendarId == null || availableCalendars == null) return null;
    for (final cal in availableCalendars) {
      {
        if (cal.id == selectedCalendarId) {
          selectedCalendar = cal;
        }
      }
    }
    return selectedCalendar;
  }

  Future<String> getRaplaUrl() async {
    return await _preferencesAccess.get<String>(raplaUrlKey) ?? "";
  }

  Future<void> setRaplaUrl(String url) async {
    await _preferencesAccess.set<String>(raplaUrlKey, url);
  }

  Future<bool> isFirstStart() async {
    return await _preferencesAccess.get<bool>(isFirstStartKey) ?? true;
  }

  Future<void> setIsFirstStart(bool isFirstStart) async {
    await _preferencesAccess.set<bool>(isFirstStartKey, isFirstStart);
  }

  Future<String?> getLastUsedLanguageCode() async {
    return _preferencesAccess.get<String>(lastUsedLanguageCode);
  }

  Future<void> setLastUsedLanguageCode(String languageCode) async {
    await _preferencesAccess.set<String>(lastUsedLanguageCode, languageCode);
  }

  Future<bool> getNotifyAboutNextDay() async {
    return await _preferencesAccess.get<bool>(notifyAboutNextDay) ?? true;
  }

  Future<void> setNotifyAboutNextDay(bool value) async {
    await _preferencesAccess.set<bool>(notifyAboutNextDay, value);
  }

  Future<bool> getNotifyAboutScheduleChanges() async {
    return await _preferencesAccess.get<bool>(notifyAboutScheduleChanges) ??
        true;
  }

  Future<void> setNotifyAboutScheduleChanges(bool value) async {
    await _preferencesAccess.set<bool>(notifyAboutScheduleChanges, value);
  }

  Future<bool> getDontShowRateNowDialog() async {
    return await _preferencesAccess.get<bool>(dontShowRateNowDialog) ?? false;
  }

  Future<void> setDontShowRateNowDialog(bool value) async {
    await _preferencesAccess.set<bool>(dontShowRateNowDialog, value);
  }

  Future<void> storeDualisCredentials(Credentials credentials) async {
    await _secureStorageAccess.set(dualisUsername, credentials.username);
    await _secureStorageAccess.set(dualisPassword, credentials.password);
  }

  Future<Credentials?> loadDualisCredentials() async {
    final username = await _secureStorageAccess.get(dualisUsername);
    final password = await _secureStorageAccess.get(dualisPassword);

    if (username == null ||
        password == null ||
        username.isEmpty ||
        password.isEmpty) return null;
    return Credentials(username, password);
  }

  Future<void> clearDualisCredentials() async {
    await _secureStorageAccess.set(dualisUsername, null);
    await _secureStorageAccess.set(dualisPassword, null);
  }

  Future<bool> getStoreDualisCredentials() async {
    return await _preferencesAccess.get<bool>(dualisStoreCredentials) ?? false;
  }

  Future<void> setStoreDualisCredentials(bool value) async {
    await _preferencesAccess.set<bool>(dualisStoreCredentials, value);
  }

  Future<String?> getLastViewedSemester() async {
    return _preferencesAccess.get<String>(lastViewedSemester);
  }

  Future<void> setLastViewedSemester(String? semester) async {
    if (semester == null) return;
    await _preferencesAccess.set<String>(lastViewedSemester, semester);
  }

  Future<String?> getLastViewedDateEntryDatabase() async {
    return _preferencesAccess.get<String>(lastViewedDateEntryDatabase);
  }

  Future<void> setLastViewedDateEntryDatabase(String value) async {
    await _preferencesAccess.set<String>(lastViewedDateEntryDatabase, value);
  }

  Future<String?> getLastViewedDateEntryYear() async {
    return _preferencesAccess.get<String>(lastViewedDateEntryYear);
  }

  Future<void> setLastViewedDateEntryYear(String? value) async {
    if (value == null) return;
    await _preferencesAccess.set<String>(lastViewedDateEntryYear, value);
  }

  Future<ScheduleSourceType> getScheduleSourceType() async {
    final type = await _preferencesAccess.get<int>(scheduleSourceType);

    if (type == null) {
      return ScheduleSourceType.none;
    }
    return ScheduleSourceType.values[type];
  }

  Future<void> setScheduleSourceType(ScheduleSourceType type) async {
    await _preferencesAccess.set<int>(scheduleSourceType, type.index);
  }

  Future<String?> getIcalUrl() {
    return _preferencesAccess.get<String>(scheduleIcalUrl);
  }

  Future<void> setIcalUrl(String url) {
    return _preferencesAccess.set<String>(scheduleIcalUrl, url);
  }

  Future<String?> getMannheimScheduleId() {
    return _preferencesAccess.get<String>(mannheimScheduleId);
  }

  Future<void> setMannheimScheduleId(String url) {
    return _preferencesAccess.set<String>(mannheimScheduleId, url);
  }

  Future<bool> getPrettifySchedule() async {
    return await _preferencesAccess.get<bool>(prettifySchedule) ?? true;
  }

  Future<void> setPrettifySchedule(bool value) {
    return _preferencesAccess.set<bool>(prettifySchedule, value);
  }

  Future<bool> getSynchronizeScheduleWithCalendar() async {
    return await _preferencesAccess
            .get<bool>(synchronizeScheduleWithCalendar) ??
        true;
  }

  Future<void> setSynchronizeScheduleWithCalendar(bool value) {
    return _preferencesAccess.set<bool>(synchronizeScheduleWithCalendar, value);
  }

  Future<bool> getDidShowWidgetHelpDialog() async {
    return await _preferencesAccess.get<bool>(didShowWidgetHelpDialog) ?? false;
  }

  Future<void> setDidShowWidgetHelpDialog(bool value) {
    return _preferencesAccess.set<bool>(didShowWidgetHelpDialog, value);
  }

  Future<void> set<T>(String key, T value) async {
    if (value == null) return;
    return _preferencesAccess.set(key, value);
  }

  Future<T?> get<T>(String key) async {
    return _preferencesAccess.get<T?>(key);
  }

  Future<int> getAppLaunchCounter() async {
    return await _preferencesAccess.get<int>("AppLaunchCount") ?? 0;
  }

  Future<void> setAppLaunchCounter(int value) async {
    return _preferencesAccess.set<int>("AppLaunchCount", value);
  }

  Future<int> getNextRateInStoreLaunchCount() async {
    return await _preferencesAccess.get<int>("NextRateInStoreLaunchCount") ??
        rateInStoreLaunchAfter;
  }

  Future<void> setNextRateInStoreLaunchCount(int value) async {
    return _preferencesAccess.set<int>("NextRateInStoreLaunchCount", value);
  }

  Future<bool> getDidShowDonateDialog() async {
    return await _preferencesAccess.get<bool>("DidShowDonateDialog") ?? false;
  }

  Future<void> setDidShowDonateDialog(bool value) {
    return _preferencesAccess.set<bool>("DidShowDonateDialog", value);
  }

  Future<bool> getHasPurchasedSomething() async {
    return await _preferencesAccess.get<bool>("HasPurchasedSomething") ?? false;
  }

  Future<void> setHasPurchasedSomething(bool value) {
    return _preferencesAccess.set<bool>("HasPurchasedSomething", value);
  }
}
