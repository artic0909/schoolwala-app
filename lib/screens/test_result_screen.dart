import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../widgets/practice_test_option.dart';
import '../widgets/custom_button.dart';
import '../services/student_service.dart';

class TestResultScreen extends StatefulWidget {
  final List<Question> questions;
  final String videoId;
  final Map<String, String> studentAnswers;
  final bool isViewOnly;
  final int? score;
  final int? totalQuestions;

  const TestResultScreen({
    super.key,
    required this.questions,
    required this.videoId,
    required this.studentAnswers,
    this.isViewOnly = false,
    this.score,
    this.totalQuestions,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  bool _isSubmitting = true;
  int _score = 0;
  int _totalQuestions = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isViewOnly) {
      _isSubmitting = false;
      _score = widget.score ?? 0;
      _totalQuestions = widget.totalQuestions ?? widget.questions.length;
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await StudentService.submitPracticeTest({
        'video_id': widget.videoId,
        'answers': widget.studentAnswers,
      });

      if (result['success'] && mounted) {
        final data = result['data'];
        final dynamic rawCorrectAnswers = data['data']['correct_answers'];

        // Handle both Map and List for correct answers
        Map<String, dynamic> correctAnswersMap = {};
        if (rawCorrectAnswers is List) {
          for (int i = 0; i < rawCorrectAnswers.length; i++) {
            correctAnswersMap[i.toString()] = rawCorrectAnswers[i];
          }
        } else if (rawCorrectAnswers is Map) {
          correctAnswersMap = Map<String, dynamic>.from(rawCorrectAnswers);
        }

        // Update questions with correct answers from backend
        for (int i = 0; i < widget.questions.length; i++) {
          final correctAnsText = correctAnswersMap[i.toString()];
          if (correctAnsText != null) {
            final String rawText = correctAnsText.toString();
            widget.questions[i].rawCorrectAnswer = rawText;

            final String targetText = rawText.trim().toLowerCase();
            final correctIdx = widget.questions[i].options.indexWhere((opt) {
              final oText = opt.trim().toLowerCase();
              return oText == targetText ||
                  oText.contains(targetText) ||
                  targetText.contains(oText);
            });
            if (correctIdx != -1) {
              widget.questions[i].correctOptionIndex = correctIdx;
            }
          }
        }

        setState(() {
          _score = data['data']['score'] ?? 0;
          _totalQuestions =
              data['data']['total_questions'] ?? widget.questions.length;
          _isSubmitting = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to submit test';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error submitting test: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate correct answers locally for display
    int correctAnswers = _score ~/ 2;
    int totalQuestions =
        _totalQuestions > 0 ? _totalQuestions : widget.questions.length;
    int totalPoints = _score;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Test Results',
          style: TextStyle(
            color: AppColors.darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.darkNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isSubmitting
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Submitting your test...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitTest,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryOrange, Color(0xFFFF9966)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$totalPoints / ${totalQuestions * 2}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You answered $correctAnswers out of $totalQuestions correct',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Review Answers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Review List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.questions.length,
                      itemBuilder: (context, index) {
                        final question = widget.questions[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.inputBorder.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.questionText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkNavy,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...List.generate(question.options.length, (
                                optIndex,
                              ) {
                                return PracticeTestOption(
                                  text: question.options[optIndex],
                                  indexLabel: String.fromCharCode(
                                    65 + optIndex,
                                  ),
                                  isSelected:
                                      question.selectedOptionIndex == optIndex,
                                  onTap: () {}, // No interaction in result
                                  showResult: true,
                                );
                              }),

                              const SizedBox(height: 12),

                              // Correct Answer Indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.inputBorder.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F7FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Color(0xFF3B9EFF),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Correct : ${question.rawCorrectAnswer ?? (question.correctOptionIndex < question.options.length ? question.options[question.correctOptionIndex] : "N/A")}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}
