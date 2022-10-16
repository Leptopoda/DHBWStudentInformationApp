import 'package:dhbwstudentapp/dualis/service/parsing/parsing_utils.dart';
import 'package:dhbwstudentapp/schedule/model/schedule_entry.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

class RaplaParsingUtils {
  const RaplaParsingUtils();

  static const String weekBlockClass = "week_block";
  static const String tooltipClasss = "tooltip";
  static const String infotableClass = "infotable";
  static const String resourceClass = "resource";
  static const String labelClass = "label";
  static const String valueClass = "value";
  static const String classNameLabel = "Veranstaltungsname:";
  static const String classNameLabelAlternative = "Name:";
  static const String classTitleLabel = "Titel:";
  static const String professorNameLabel = "Personen:";
  static const String detailsLabel = "Bemerkung:";
  static const String resourcesLabel = "Ressourcen:";

  static const Map<String, ScheduleEntryType> entryTypeMapping = {
    "Feiertag": ScheduleEntryType.publicHoliday,
    "Online-Format (ohne Raumbelegung)": ScheduleEntryType.online,
    "Vorlesung / Lehrbetrieb": ScheduleEntryType.lesson,
    "Lehrveranstaltung": ScheduleEntryType.lesson,
    "Klausur / Prüfung": ScheduleEntryType.exam,
    "Prüfung": ScheduleEntryType.exam
  };

  static ScheduleEntry extractScheduleEntryOrThrow(
    Element value,
    DateTime date,
  ) {
    // The tooltip tag contains the most relevant information
    final tooltip = value.getElementsByClassName(tooltipClasss);

    // The only reliable way to extract the time
    final timeAndClassName = value.getElementsByTagName("a");

    if (timeAndClassName.isEmpty) {
      throw ElementNotFoundParseException("time and date container");
    }

    final descriptionInCell = timeAndClassName[0].text;

    final start = _parseTime(descriptionInCell.substring(0, 5), date);
    final end = _parseTime(descriptionInCell.substring(7, 12), date);

    if (start == null || end == null) {
      throw ElementNotFoundParseException("start and end date container");
    }

    ScheduleEntry? scheduleEntry;

    // The important information is stored in a html element called tooltip.
    // Depending on the Rapla configuration the tooltip is available or not.
    // When there is no tooltip fallback to extract the available information
    // From the cell itself.
    // TODO: Display a warning that information is not extracted from the
    //       tooltip. Then provide a link with a manual to activate it in Rapla
    if (tooltip.isEmpty) {
      scheduleEntry = extractScheduleDetailsFromCell(
        timeAndClassName,
        scheduleEntry,
        start,
        end,
      );
    } else {
      scheduleEntry =
          extractScheduleFromTooltip(tooltip, value, scheduleEntry, start, end);
    }

    return improveScheduleEntry(scheduleEntry);
  }

  static ScheduleEntry improveScheduleEntry(ScheduleEntry scheduleEntry) {
    if (scheduleEntry.title.isEmpty) {
      throw ElementNotFoundParseException("title");
    }

    final professor = scheduleEntry.professor;
    if (professor.endsWith(",")) {
      scheduleEntry = scheduleEntry.copyWith(
        professor: professor.substring(0, professor.length - 1),
      );
    }

    return scheduleEntry.copyWith(
      title: trimAndEscapeString(scheduleEntry.title),
      details: trimAndEscapeString(scheduleEntry.details),
      professor: trimAndEscapeString(scheduleEntry.professor),
      room: trimAndEscapeString(scheduleEntry.room),
    );
  }

  static ScheduleEntry extractScheduleFromTooltip(
    List<Element> tooltip,
    Element value,
    ScheduleEntry? scheduleEntry,
    DateTime start,
    DateTime end,
  ) {
    final infotable = tooltip[0].getElementsByClassName(infotableClass);

    if (infotable.isEmpty) {
      throw ElementNotFoundParseException("infotable container");
    }

    final Map<String, String> properties = _parsePropertiesTable(infotable[0]);
    final type = _extractEntryType(tooltip);
    final title = properties[classNameLabel] ??
        properties[classTitleLabel] ??
        properties[classNameLabelAlternative];

    final professor = properties[professorNameLabel];
    final details = properties[detailsLabel];
    final resource = properties[resourcesLabel] ?? _extractResources(value);

    return ScheduleEntry(
      start: start,
      end: end,
      title: title,
      details: details,
      professor: professor,
      type: type,
      room: resource,
    );
  }

  static ScheduleEntry extractScheduleDetailsFromCell(
    List<Element> timeAndClassName,
    ScheduleEntry? scheduleEntry,
    DateTime start,
    DateTime end,
  ) {
    final descriptionHtml = timeAndClassName[0].innerHtml.substring(12);
    final descriptionParts = descriptionHtml.split("<br>");

    var title = "";
    var details = "";

    if (descriptionParts.length == 1) {
      title = descriptionParts[0];
    } else if (descriptionParts.isNotEmpty) {
      title = descriptionParts[1];
      details = descriptionParts.join("\n");
    }

    return ScheduleEntry(
      start: start,
      end: end,
      title: title,
      details: details,
      professor: "",
      type: ScheduleEntryType.unknown,
      room: "",
    );
  }

  static ScheduleEntryType _extractEntryType(List<Element> tooltip) {
    if (tooltip.isEmpty) return ScheduleEntryType.unknown;

    final strongTag = tooltip[0].getElementsByTagName("strong");
    if (strongTag.isEmpty) return ScheduleEntryType.unknown;

    final typeString = strongTag[0].innerHtml;

    if (entryTypeMapping.containsKey(typeString)) {
      return entryTypeMapping[typeString]!;
    } else {
      return ScheduleEntryType.unknown;
    }
  }

  static Map<String, String> _parsePropertiesTable(Element infotable) {
    final map = <String, String>{};
    final labels = infotable.getElementsByClassName(labelClass);
    final values = infotable.getElementsByClassName(valueClass);

    for (var i = 0; i < labels.length; i++) {
      map[labels[i].innerHtml] = values[i].innerHtml;
    }
    return map;
  }

  static DateTime? _parseTime(String timeString, DateTime date) {
    try {
      final time = DateFormat("HH:mm").parse(timeString.substring(0, 5));
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } catch (e) {
      return null;
    }
  }

  static String _extractResources(Element value) {
    final resources = value.getElementsByClassName(resourceClass);

    final resourcesList = <String>[];
    for (final resource in resources) {
      resourcesList.add(resource.innerHtml);
    }

    final buffer = StringBuffer();
    buffer.writeAll(resourcesList, ", ");

    return buffer.toString();
  }

  static String readYearOrThrow(Document document) {
    // The only reliable way to read the year of this schedule is to parse the
    // selected year in the date selector
    final comboBoxes = document.getElementsByTagName("select");

    String? year;
    for (final box in comboBoxes) {
      if (box.attributes.containsKey("name") &&
          box.attributes["name"] == "year") {
        final entries = box.getElementsByTagName("option");

        for (final entry in entries) {
          if (entry.attributes.containsKey("selected") &&
              entry.attributes["selected"] == "") {
            year = entry.text;

            break;
          }
        }

        break;
      }
    }

    if (year == null) {
      throw ElementNotFoundParseException("year");
    }

    return year;
  }
}
