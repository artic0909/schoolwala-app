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
    Color labelBgColor = AppColors.primaryOrange.withValues(alpha: 0.1);
    Widget? trailingIcon;
    double borderWidth = 1.0;

    if (showResult) {
      if (isCorrectAnswer) {
        // Correct answer: green border, light green background, check icon
        borderColor = const Color(0xFF22C55E); // Green
        backgroundColor = const Color(0xFFF0FDF4); // Light Green
        textColor = const Color(0xFF15803D);
        labelColor = Colors.white;
        labelBgColor = const Color(0xFF22C55E);
        borderWidth = 2.0;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF22C55E),
          size: 22,
        );
      } else if (isWrongAnswer) {
        // Selected wrong answer: red border, light red background, cross icon
        borderColor = const Color(0xFFEF4444); // Red
        backgroundColor = const Color(0xFFFEF2F2); // Light Red
        textColor = const Color(0xFFB91C1C);
        labelColor = Colors.white;
        labelBgColor = const Color(0xFFEF4444);
        borderWidth = 2.0;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFEF4444),
          size: 22,
        );
      } else {
        // Other neutral options in result
        borderColor = AppColors.inputBorder.withValues(alpha: 0.6);
        backgroundColor = Colors.white;
        textColor = AppColors.textGray;
        labelColor = AppColors.textGray;
        labelBgColor = AppColors.inputBackground;
        borderWidth = 1.0;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primaryOrange;
        backgroundColor = AppColors.primaryOrange.withValues(alpha: 0.05);
        labelColor = Colors.white;
        labelBgColor = AppColors.primaryOrange;
        borderWidth = 2.0;
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
            width: borderWidth,
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
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}
