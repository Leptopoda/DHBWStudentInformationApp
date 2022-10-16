import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dhbwstudentapp/common/data/epoch_date_time_converter.dart';
import 'package:dhbwstudentapp/common/ui/schedule_entry_theme.dart';
import 'package:dhbwstudentapp/dualis/service/parsing/parsing_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_entry.g.dart';

enum ScheduleEntryType {
  unknown,
  lesson,
  online,
  publicHoliday,
  exam;

  Color color(BuildContext context) {
    final scheduleEntryTheme =
        Theme.of(context).extension<ScheduleEntryTheme>()!;

    switch (this) {
      case ScheduleEntryType.publicHoliday:
        return scheduleEntryTheme.publicHoliday;
      case ScheduleEntryType.lesson:
        return scheduleEntryTheme.lesson;
      case ScheduleEntryType.exam:
        return scheduleEntryTheme.exam;
      case ScheduleEntryType.online:
        return scheduleEntryTheme.online;
      case ScheduleEntryType.unknown:
        return scheduleEntryTheme.unknown;
    }
  }
}

@CopyWith()
@JsonSerializable()
class ScheduleEntry extends Equatable {
  final int? id;
  @EpochDateTimeConverter()
  final DateTime start;
  @EpochDateTimeConverter()
  final DateTime end;
  final String title;
  final String details;
  final String professor;
  final String room;
  @JsonKey(
    toJson: _typeToJson,
    fromJson: _typeFromJson,
  )
  final ScheduleEntryType type;

  ScheduleEntry({
    this.id,
    DateTime? start,
    DateTime? end,
    String? title,
    String? details,
    String? professor,
    String? room,
    required this.type,
  })  : start = start ?? DateTime.fromMicrosecondsSinceEpoch(0),
        end = end ?? DateTime.fromMicrosecondsSinceEpoch(0),
        details = details ?? "",
        professor = professor ?? "",
        room = room ?? "",
        title = title ?? "";

  List<String> getDifferentProperties(ScheduleEntry entry) {
    final changedProperties = <String>[];

    if (title != entry.title) {
      changedProperties.add("title");
    }
    if (start != entry.start) {
      changedProperties.add("start");
    }
    if (end != entry.end) {
      changedProperties.add("end");
    }
    if (details != entry.details) {
      changedProperties.add("details");
    }
    if (professor != entry.professor) {
      changedProperties.add("professor");
    }
    if (room != entry.room) {
      changedProperties.add("room");
    }
    if (type != entry.type) {
      changedProperties.add("type");
    }

    return changedProperties;
  }

  ScheduleEntry improve() {
    if (title.isEmpty) {
      throw ElementNotFoundParseException("title");
    }

    String? professorCleaned;
    if (professor.endsWith(",")) {
      professorCleaned = professor.substring(0, professor.length - 1);
    }

    return copyWith(
      title: trimAndEscapeString(title),
      details: trimAndEscapeString(details),
      professor: trimAndEscapeString(professorCleaned ?? professor),
      room: trimAndEscapeString(room),
    );
  }

  ScheduleEntry prettify() {
    return _removeOnlinePrefix()._removeCourseFromTitle();
  }

  ScheduleEntry _removeOnlinePrefix() {
    // Sometimes the entry type is not set correctly. When the title of a class
    // begins with "Online - " it implies that it is online
    // In this case remove the online prefix and set the type correctly
    final onlinePrefixRegExp =
        RegExp(r'\(?online\)?([ -]*)', caseSensitive: false);
    final onlineSuffixRegExp =
        RegExp(r'([ -]*)\(?online\)?', caseSensitive: false);

    var newTitle = title;
    newTitle = newTitle.replaceFirst(onlinePrefixRegExp, "");
    newTitle = newTitle.replaceFirst(onlineSuffixRegExp, "");

    if (newTitle == title) {
      return this;
    }

    const type = ScheduleEntryType.online;

    return copyWith(title: newTitle, type: type);
  }

  ScheduleEntry _removeCourseFromTitle() {
    var newTitle = title;
    var newDetails = details;

    final titleRegex =
        RegExp("[A-Z]{3,}-?[A-Z]+[0-9]*[A-Z]*[0-9]*[/]?[A-Z]*[0-9]*[ ]*-?");
    final match = titleRegex.firstMatch(title);

    if (match != null && match.start == 0) {
      newDetails = "${newTitle.substring(0, match.end)} - $newDetails";
      newTitle = newTitle.substring(match.end).trim();
    } else {
      final first = newTitle.split(" ").first;

      // Prettify titles: T3MB9025 Fluidmechanik -> Fluidmechanik

      // The title can not be prettified, if the first word is not only uppercase
      // or less than 2 charcters long
      if (!(first == first.toUpperCase() && first.length >= 3)) return this;

      final numberCount = first.split(RegExp("[0-9]")).length;

      // If there are less thant two numbers in the title, do not prettify it
      if (numberCount < 2) return this;

      newDetails = "${newTitle.substring(0, first.length)} - $newDetails";
      newTitle = newTitle.substring(first.length).trim();
    }

    return copyWith(title: newTitle, details: newDetails);
  }

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleEntryToJson(this);

  static const tableName = "ScheduleEntries";

  static int _typeToJson(ScheduleEntryType value) => value.index;
  static ScheduleEntryType _typeFromJson(int value) =>
      ScheduleEntryType.values[value];

  @override
  List<Object?> get props =>
      [start, end, title, details, professor, room, type];
}
