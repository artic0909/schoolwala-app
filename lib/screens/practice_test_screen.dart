import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../widgets/practice_test_option.dart';
import '../widgets/custom_button.dart';
import '../services/student_service.dart';
import 'test_result_screen.dart';

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
        final List<dynamic> questions = data['data']['questions'] ?? [];
        final List<dynamic> options = data['data']['options'] ?? [];
        _videoTitle = data['data']['video_title'] ?? widget.videoTitle;

        // Build Question objects
        List<Question> loadedQuestions = [];
        for (int i = 0; i < questions.length; i++) {
          if (i < options.length) {
            // Parse options - they can be arrays or comma-separated strings
            List<String> questionOptions = [];
            if (options[i] is List) {
              questionOptions = List<String>.from(options[i]);
            } else if (options[i] is String) {
              questionOptions =
                  options[i]
                      .toString()
                      .split(',')
                      .map((e) => e.trim())
                      .toList();
            }

            loadedQuestions.add(
              Question(
                id: i + 1,
                questionText: questions[i].toString(),
                options: questionOptions,
                correctOptionIndex: 0, // Will be revealed after submission
              ),
            );
          }
        }

        setState(() {
          _questions = loadedQuestions;
          _isLoading = false;
        });
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
              Map<String, String> answers = {};
              for (int i = 0; i < _questions.length; i++) {
                answers[i.toString()] =
                    _questions[i].selectedOptionIndex.toString();
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
