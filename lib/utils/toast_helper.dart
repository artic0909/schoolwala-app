import 'package:flutter/material.dart';

class ToastHelper {
  static void _showToast(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFF10B981), Icons.check_circle_outline); // Emerald Green
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFFEF4444), Icons.error_outline); // Red
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFF3B82F6), Icons.info_outline); // Blue
  }
}
