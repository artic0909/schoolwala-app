import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../widgets/practice_test_option.dart';
import '../widgets/custom_button.dart';
import '../services/student_service.dart';
import 'test_result_screen.dart';
import '../widgets/global_bottom_bar.dart';

class PracticeTestScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;

  const PracticeTestScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _videoTitle = '';

  @override
  void initState() {
    super.initState();
    _loadPracticeTest();
  }

  Future<void> _loadPracticeTest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await StudentService.getPracticeTest(widget.videoId);

      if (result['success'] && mounted) {
        final data = result['data'];

        // Extract data from API response
        final List<dynamic> questionsList = data['data']['questions'] ?? [];
        final List<dynamic> optionsList = data['data']['options'] ?? [];

        final dynamic rawCorrectAnswers = data['data']['correct_answers'];
        final dynamic rawSubmittedTest = data['data']['submitted_test'];

        // Handle both Map and List for correct answers
        Map<String, dynamic> correctAnswersMap = {};
        if (rawCorrectAnswers is List) {
          for (int i = 0; i < rawCorrectAnswers.length; i++) {
            correctAnswersMap[i.toString()] = rawCorrectAnswers[i];
          }
        } else if (rawCorrectAnswers is Map) {
          correctAnswersMap = Map<String, dynamic>.from(rawCorrectAnswers);
        }

        final Map<String, dynamic>? submittedTest =
            rawSubmittedTest != null
                ? Map<String, dynamic>.from(rawSubmittedTest)
                : null;

        // Parse student answers robustly
        Map<String, dynamic> studentAnswersMap = {};
        if (submittedTest != null && submittedTest['student_answers'] != null) {
          dynamic rawAnswers = submittedTest['student_answers'];
          if (rawAnswers is String) {
            try {
              rawAnswers = json.decode(rawAnswers);
            } catch (e) {
              rawAnswers = {};
            }
          }

          if (rawAnswers is List) {
            for (int i = 0; i < rawAnswers.length; i++) {
              studentAnswersMap[i.toString()] = rawAnswers[i];
            }
          } else if (rawAnswers is Map) {
            studentAnswersMap = Map<String, dynamic>.from(rawAnswers);
          }
        }
        final Map<String, dynamic>? studentAnswers =
            studentAnswersMap.isEmpty ? null : studentAnswersMap;

        _videoTitle = data['data']['video_title'] ?? widget.videoTitle;

        // Build Question objects
        List<Question> loadedQuestions = [];
        for (int i = 0; i < questionsList.length; i++) {
          if (i < optionsList.length) {
            // Parse options
            List<String> questionOptions = [];
            if (optionsList[i] is List) {
              questionOptions = List<String>.from(optionsList[i]);
            } else if (optionsList[i] is String) {
              questionOptions =
                  optionsList[i]
                      .toString()
                      .split(',')
                      .map((e) => e.trim())
                      .toList();
            }

            int correctIdx = 0;
            String? rawCorrect;
            if (correctAnswersMap.containsKey(i.toString())) {
              rawCorrect = correctAnswersMap[i.toString()].toString();
              final cText = rawCorrect.trim().toLowerCase();

              // Robust matching
              correctIdx = questionOptions.indexWhere((opt) {
                final oText = opt.trim().toLowerCase();
                return oText == cText ||
                    oText.contains(cText) ||
                    cText.contains(oText);
              });
              if (correctIdx == -1) correctIdx = 0;
            }

            int? selectedIdx;
            String? rawStudent;
            if (studentAnswersMap.isNotEmpty &&
                studentAnswersMap[i.toString()] != null) {
              rawStudent = studentAnswersMap[i.toString()].toString();
              final sText = rawStudent.trim().toLowerCase();

              selectedIdx = questionOptions.indexWhere((opt) {
                final oText = opt.trim().toLowerCase();
                return oText == sText ||
                    oText.contains(sText) ||
                    sText.contains(oText);
              });
            }

            loadedQuestions.add(
              Question(
                id: i + 1,
                questionText: questionsList[i].toString(),
                options: questionOptions,
                correctOptionIndex: correctIdx,
                selectedOptionIndex: selectedIdx,
                rawCorrectAnswer: rawCorrect,
                rawStudentAnswer: rawStudent,
              ),
            );
          }
        }

        setState(() {
          _questions = loadedQuestions;
          _isLoading = false;
        });

        // If already submitted, navigate to results directly
        if (submittedTest != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TestResultScreen(
                      questions: _questions,
                      videoId: widget.videoId,
                      studentAnswers: Map<String, String>.from(
                        studentAnswers ?? {},
                      ),
                      isViewOnly: true,
                      score: submittedTest['score'],
                    ),
              ),
            );
          });
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load practice test';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading practice test: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
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
                        onPressed: _loadPracticeTest,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : _buildTestContent(),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 2),
    );
  }

  Widget _buildTestContent() {
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available for this test.'));
    }
    // Calculate progress
    int answeredCount =
        _questions.where((q) => q.selectedOptionIndex != null).length;
    double progress = answeredCount / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Practice Test: ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextSpan(
                        text:
                            _videoTitle.isNotEmpty
                                ? _videoTitle
                                : widget.videoTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Test your knowledge with these questions!\\nChoose the correct answers and see how well you understand the concepts.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatBadge(
                  Icons.help_outline,
                  '${_questions.length} Questions',
                ),
                const SizedBox(width: 8),
                _buildStatBadge(Icons.access_time, 'Estimated time: 10 mins'),
                const SizedBox(width: 8),
                _buildStatBadge(
                  Icons.emoji_events_outlined,
                  'Earn ${_questions.length * 2} points',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Test Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primaryOrange,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Questions List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(question.options.length, (optIndex) {
                      return PracticeTestOption(
                        text: question.options[optIndex],
                        indexLabel: String.fromCharCode(
                          65 + optIndex,
                        ), // A, B, C...
                        isSelected: question.selectedOptionIndex == optIndex,
                        onTap: () {
                          setState(() {
                            question.selectedOptionIndex = optIndex;
                          });
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          CustomButton(
            text: 'Submit Test',
            onPressed: () {
              // Check if all questions are answered
              int unansweredCount =
                  _questions.where((q) => q.selectedOptionIndex == null).length;

              if (unansweredCount > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please answer all questions before submitting. ($unansweredCount unanswered)',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Prepare answers for submission
              // Prepare answers map
              Map<String, String> answers = {};
              for (int i = 0; i < _questions.length; i++) {
                if (_questions[i].selectedOptionIndex != null) {
                  // Send the actual text of the answer instead of index
                  // because backend expects string to compare with correct_answers
                  answers[i.toString()] =
                      _questions[i].options[_questions[i].selectedOptionIndex!];
                }
              }

              // Navigate to results screen which will submit to backend
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TestResultScreen(
                        questions: _questions,
                        videoId: widget.videoId,
                        studentAnswers: answers,
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5), // Light orange bg
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryOrange),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
