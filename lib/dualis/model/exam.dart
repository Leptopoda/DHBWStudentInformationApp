import 'package:dhbwstudentapp/dualis/model/exam_grade.dart';

enum ExamState {
  passed,
  failed,
  pending,
}

class Exam {
  final String? name;
  final ExamGrade grade;
  final String? semester;
  final ExamState state;

  const Exam(
    this.name,
    this.grade,
    this.state,
    this.semester,
  );
}
