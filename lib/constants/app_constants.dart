import 'package:flutter/material.dart';

// App Colors
class AppColors {
  // Primary Brand Colors
  static const Color primaryOrange = Color(0xFFFF9933);
  static const Color deepOrange = Color(0xFFFF8C00);
  static const Color lightOrange = Color(0xFFFFB366);
  static const Color peachOrange = Color(0xFFFFD4A3);

  // Secondary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightLavender = Color(0xFFE8E8FF);
  static const Color inputBackground = Color(0xFFF5F5FF);
  static const Color darkNavy = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color inputBorder = Color(0xFFE5E7EB);

  // Gradient Colors
  static const List<Color> orangeGradient = [
    Color(0xFFFFB366),
    Color(0xFFFF9933),
    Color(0xFFFF8C00),
  ];

  static const List<Color> decorativeGradient = [
    Color(0xFFFF9933),
    Color(0xFFFF6B6B),
  ];
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkNavy,
    fontFamily: 'Poppins',
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
    fontFamily: 'Poppins',
  );

  static const TextStyle splashTitle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    fontFamily: 'Poppins',
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkNavy,
    fontFamily: 'Poppins',
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryOrange,
    fontFamily: 'Poppins',
  );
}

// App Constants
class AppConstants {
  static const String appName = 'Schoolwala';
  static const String tagline = 'Education for All';
  static const String welcomeBack = 'Welcome back!';
  static const String signInSubtitle =
      'Sign in to continue your child\'s learning journey';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 4);
  static const Duration logoAnimationDuration = Duration(milliseconds: 1500);
  static const Duration textAnimationDelay = Duration(milliseconds: 800);
}
