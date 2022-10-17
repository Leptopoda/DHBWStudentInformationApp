import 'package:dhbwstudentapp/common/i18n/localizations.dart';
import 'package:flutter/widgets.dart';

enum _ExamGradeState {
  notGraded,
  graded,
  passed,
  failed,
}

class ExamGrade {
  final _ExamGradeState _state;
  final String? _gradeValue;

  const ExamGrade.failed()
      : _state = _ExamGradeState.failed,
        _gradeValue = null;

  const ExamGrade.notGraded()
      : _state = _ExamGradeState.notGraded,
        _gradeValue = null;

  const ExamGrade.passed()
      : _state = _ExamGradeState.passed,
        _gradeValue = null;

  ExamGrade.graded(this._gradeValue) : _state = _ExamGradeState.graded;

  factory ExamGrade.fromString(String? grade) {
    if (grade == "noch nicht gesetzt" || grade == "") {
      return const ExamGrade.notGraded();
    }

    if (grade == "b") {
      return const ExamGrade.passed();
    }

    // TODO: Determine the value when a exam is in the "failed" state
    //if (grade == "") {
    //  return ExamGrade.failed();
    //}

    return ExamGrade.graded(grade);
  }

  String getText(BuildContext context) {
    switch (_state) {
      case _ExamGradeState.notGraded:
        return "";
      case _ExamGradeState.graded:
        return _gradeValue!;
      case _ExamGradeState.passed:
        return L.of(context).examPassed;
      case _ExamGradeState.failed:
        return L.of(context).examNotPassed;
    }
  }
}
