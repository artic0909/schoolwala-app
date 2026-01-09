class Question {
  final int id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  int? selectedOptionIndex;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
  });
}
