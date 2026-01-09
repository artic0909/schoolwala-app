import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class PracticeTestOption extends StatelessWidget {
  final String text;
  final String indexLabel; // A, B, C, D
  final bool isSelected;
  final VoidCallback onTap;

  // For Result Screen logic
  final bool isCorrectAnswer;
  final bool isWrongAnswer;
  final bool showResult;

  const PracticeTestOption({
    super.key,
    required this.text,
    required this.indexLabel,
    required this.isSelected,
    required this.onTap,
    this.isCorrectAnswer = false,
    this.isWrongAnswer = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.inputBorder;
    Color backgroundColor = Colors.white;
    Color textColor = AppColors.darkNavy;
    Color labelColor = AppColors.primaryOrange;
    Color labelBgColor = AppColors.primaryOrange.withOpacity(0.1);

    if (showResult) {
      if (isCorrectAnswer) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.05);
        textColor = Colors.green[800]!;
        labelColor = Colors.white;
        labelBgColor = Colors.green;
      } else if (isWrongAnswer) {
        borderColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.05);
        textColor = Colors.red[800]!;
        labelColor = Colors.white;
        labelBgColor = Colors.red;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primaryOrange;
        backgroundColor = AppColors.primaryOrange.withOpacity(0.05);
        labelColor = Colors.white;
        labelBgColor = AppColors.primaryOrange;
      }
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width:
                isSelected || (showResult && (isCorrectAnswer || isWrongAnswer))
                    ? 2
                    : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                indexLabel,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showResult && isCorrectAnswer)
              const Icon(Icons.check_circle, color: Colors.green),
            if (showResult && isWrongAnswer)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
