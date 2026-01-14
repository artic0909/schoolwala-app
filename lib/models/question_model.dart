class Question {
  final int id;
  final String questionText;
  final List<String> options;
  int correctOptionIndex;
  int? selectedOptionIndex;
  String? rawCorrectAnswer;
  String? rawStudentAnswer;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
    this.rawCorrectAnswer,
    this.rawStudentAnswer,
  });
}
