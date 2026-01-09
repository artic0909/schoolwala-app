import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../widgets/practice_test_option.dart';
import '../widgets/custom_button.dart';
import 'test_result_screen.dart';

class PracticeTestScreen extends StatefulWidget {
  const PracticeTestScreen({super.key});

  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  // Sample Data (mimicking the image)
  final List<Question> _questions = [
    Question(
      id: 1,
      questionText:
          '"বোঝাপড়া" কবিতাটি রবীন্দ্রনাথ ঠাকুরের কোন কাব্যগ্রন্থের অন্তর্গত?',
      options: ['গীতাঞ্জলি', 'মানসী', 'ক্ষণিকা', 'বলাকা'],
      correctOptionIndex: 2, // Assuming 'ক্ষণিকা'
    ),
    Question(
      id: 2,
      questionText: '"বোঝাপড়া" কবিতায় কবি কী মেনে নেওয়ার কথা বলেছেন?',
      options: [
        'জীবনের দুঃখ-কষ্ট',
        'মানুষের পরিবর্তনশীলতা',
        'ভাগ্যের নির্মম পরিহাস',
        'উপরের সবগুলি',
      ],
      correctOptionIndex: 0, // Assuming
    ),
    Question(
      id: 3,
      questionText:
          '"কেউ বা ডরায়ে থাকে, কেউ বা ডরায়ে না" - এখানে কীসের প্রতি ইঙ্গিত করা হয়েছে?',
      options: ['মৃত্যুভয়', 'সমাজভয়', 'ভবিষ্যৎ', 'ভাগ্য'],
      correctOptionIndex: 3, // Assuming
    ),
    Question(
      id: 4,
      questionText: 'রবীন্দ্রনাথ ঠাকুর কত সালে নোবেল পুরস্কার পান?',
      options: ['১৯১১', '১৯১৩', '১৯২১', '১৯৪১'],
      correctOptionIndex: 1, // 1913
    ),
    Question(
      id: 5,
      questionText: '"বোঝাপড়া" কবিতার মূল ভাব কী?',
      options: [
        'বিদ্রোহ',
        'আত্মসমর্পন',
        'বাস্তবতা মেনে নেওয়া',
        'প্রকৃতি প্রেম',
      ],
      correctOptionIndex: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    int answeredCount =
        _questions.where((q) => q.selectedOptionIndex != null).length;
    double progress = answeredCount / _questions.length;

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
      body: SingleChildScrollView(
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
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Practice Test: ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        TextSpan(
                          text: 'বোঝাপড়া',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                            // Use a Bengali supportive font if available, else default
                          ),
                        ),
                        TextSpan(
                          text: ' - Class 8',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test your knowledge about " বোঝাপড়া " with these fun questions!\nChoose the correct answers and see how well you understand the concepts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    'Earn ${_questions.length * 10} points',
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
                // Check if all answered? Or allow partial submission?
                // For now, allow partial but warn or just submit.
                // Let's just navigate to results.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TestResultScreen(questions: _questions),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
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
