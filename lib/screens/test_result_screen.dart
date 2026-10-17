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

      // Ensure student answer selection is synced
      for (int i = 0; i < widget.questions.length; i++) {
        final q = widget.questions[i];
        if (q.selectedOptionIndex == null) {
          final sAns = widget.studentAnswers[i.toString()] ??
              widget.studentAnswers[q.id.toString()] ??
              q.rawStudentAnswer;
          if (sAns != null) {
            final sText = sAns.trim().toLowerCase();
            final sIdx = q.options.indexWhere((opt) {
              final oText = opt.trim().toLowerCase();
              return oText == sText ||
                  oText.contains(sText) ||
                  sText.contains(oText);
            });
            if (sIdx != -1) {
              q.selectedOptionIndex = sIdx;
            }
          }
        }
      }
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
          final correctAnsText = correctAnswersMap[i.toString()] ??
              correctAnswersMap[widget.questions[i].id.toString()];
          if (correctAnsText != null) {
            final String rawText = correctAnsText.toString();
            widget.questions[i].rawCorrectAnswer = rawText;

            final String targetText = rawText.trim().toLowerCase();
            int correctIdx = widget.questions[i].options.indexWhere((opt) {
              final oText = opt.trim().toLowerCase();
              return oText == targetText ||
                  oText.contains(targetText) ||
                  targetText.contains(oText);
            });
            if (correctIdx == -1) {
              if (targetText == 'a' || targetText == '0') {
                correctIdx = 0;
              } else if (targetText == 'b' || targetText == '1') {
                correctIdx = 1;
              } else if (targetText == 'c' || targetText == '2') {
                correctIdx = 2;
              } else if (targetText == 'd' || targetText == '3') {
                correctIdx = 3;
              }
            }
            if (correctIdx != -1) {
              widget.questions[i].correctOptionIndex = correctIdx;
            }
          }

          // Ensure student answer selection is synced
          if (widget.questions[i].selectedOptionIndex == null) {
            final sAns = widget.studentAnswers[i.toString()] ??
                widget.studentAnswers[widget.questions[i].id.toString()] ??
                widget.questions[i].rawStudentAnswer;
            if (sAns != null) {
              final sText = sAns.trim().toLowerCase();
              final sIdx = widget.questions[i].options.indexWhere((opt) {
                final oText = opt.trim().toLowerCase();
                return oText == sText ||
                    oText.contains(sText) ||
                    sText.contains(oText);
              });
              if (sIdx != -1) {
                widget.questions[i].selectedOptionIndex = sIdx;
              }
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

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate correct answers locally for display
    int correctAnswers = _score ~/ 2;
    int totalQuestions =
        _totalQuestions > 0 ? _totalQuestions : widget.questions.length;
    int totalPoints = _score;
    double percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Test Result',
          style: TextStyle(
            color: AppColors.darkNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkNavy, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryOrange),
                  SizedBox(height: 16),
                  Text(
                    'Calculating your score...',
                    style: TextStyle(color: AppColors.textGray, fontSize: 15),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Result Banner
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF9933),
                              Color(0xFFFF7A00),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Trophy / Feedback pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  percentage >= 0.8
                                      ? 'Outstanding Job!'
                                      : percentage >= 0.5
                                          ? 'Well Done!'
                                          : 'Keep Practicing!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Score text
                            Text(
                              '$totalPoints / ${totalQuestions * 2}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score Achieved • $correctAnswers of $totalQuestions Correct',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Performance Stats Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.check_circle_rounded,
                                    iconColor: const Color(0xFF4ADE80),
                                    label: 'Correct',
                                    value: '$correctAnswers',
                                  ),
                                  Container(
                                    height: 28,
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.cancel_rounded,
                                    iconColor: const Color(0xFFF87171),
                                    label: 'Incorrect',
                                    value: '${totalQuestions - correctAnswers}',
                                  ),
                                  Container(
                                    height: 28,
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  _buildStatItem(
                                    icon: Icons.pie_chart_rounded,
                                    iconColor: Colors.white,
                                    label: 'Accuracy',
                                    value: '${(percentage * 100).toInt()}%',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section Header
                      Row(
                        children: [
                          const Text(
                            'Review Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$totalQuestions Questions',
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Questions Review List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.questions.length,
                        itemBuilder: (context, index) {
                          final question = widget.questions[index];
                          final bool isUserCorrect =
                              question.selectedOptionIndex != null &&
                              question.selectedOptionIndex == question.correctOptionIndex;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isUserCorrect
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.35)
                                    : const Color(0xFFEF4444).withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question Header (Number pill + Result pill)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Q${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUserCorrect
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isUserCorrect
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded,
                                            size: 14,
                                            color: isUserCorrect
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isUserCorrect ? 'Correct' : 'Incorrect',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isUserCorrect
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Question Text
                                Text(
                                  question.questionText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkNavy,
                                    height: 1.45,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Options
                                ...List.generate(question.options.length, (optIndex) {
                                  final bool isSelected =
                                      question.selectedOptionIndex == optIndex;
                                  final bool isCorrect =
                                      question.correctOptionIndex == optIndex;
                                  final bool isWrong = isSelected && !isCorrect;

                                  return PracticeTestOption(
                                    text: question.options[optIndex],
                                    indexLabel: String.fromCharCode(65 + optIndex),
                                    isSelected: isSelected,
                                    isCorrectAnswer: isCorrect,
                                    isWrongAnswer: isWrong,
                                    onTap: () {},
                                    showResult: true,
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Done Button
                      CustomButton(
                        text: 'Done',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
