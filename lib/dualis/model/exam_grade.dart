enum ExamGradeState {
  notGraded,
  graded,
  passed,
  failed,
}

// TODO: [leptopoda] implement into the enum
class ExamGrade {
  final ExamGradeState state;
  final String? gradeValue;

  const ExamGrade.failed()
      : state = ExamGradeState.failed,
        gradeValue = "";

  const ExamGrade.notGraded()
      : state = ExamGradeState.notGraded,
        gradeValue = "";

  const ExamGrade.passed()
      : state = ExamGradeState.passed,
        gradeValue = "";

  ExamGrade.graded(this.gradeValue) : state = ExamGradeState.graded;

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
}
