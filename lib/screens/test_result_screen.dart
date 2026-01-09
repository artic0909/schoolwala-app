import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/question_model.dart';
import '../widgets/practice_test_option.dart';
import '../widgets/custom_button.dart';

class TestResultScreen extends StatelessWidget {
  final List<Question> questions;

  const TestResultScreen({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    for (var q in questions) {
      if (q.selectedOptionIndex == q.correctOptionIndex) {
        correctAnswers++;
      }
    }
    int totalPoints = correctAnswers * 10; // 10 points per question
    int totalQuestions = questions.length;

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
          onPressed:
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
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
                    '$totalPoints / ${totalQuestions * 10}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You answered $correctAnswers out of $totalQuestions correctly',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isCorrect =
                    question.selectedOptionIndex == question.correctOptionIndex;

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
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 18,
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
                          indexLabel: String.fromCharCode(65 + optIndex),
                          isSelected: question.selectedOptionIndex == optIndex,
                          onTap: () {}, // No interaction in result
                          showResult: true,
                          isCorrectAnswer:
                              optIndex == question.correctOptionIndex,
                          isWrongAnswer:
                              (question.selectedOptionIndex == optIndex) &&
                              (question.selectedOptionIndex !=
                                  question.correctOptionIndex),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: 'Back to Home',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
