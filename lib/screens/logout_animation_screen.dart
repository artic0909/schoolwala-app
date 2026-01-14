import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../constants/app_constants.dart';

class LogoutAnimationScreen extends StatefulWidget {
  const LogoutAnimationScreen({super.key});

  @override
  State<LogoutAnimationScreen> createState() => _LogoutAnimationScreenState();
}

class _LogoutAnimationScreenState extends State<LogoutAnimationScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cute crying animation/gif
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMngxZ3FqZnlxZnhqZnhqZnhqZnhqZnhqZnhqZnhqZnhqZnhqJmVwPXYxX2ludGVybmFsX2dpZl9ieV9pZCZjdD1n/OPU6wUKDX8jkyTOE6/giphy.gif',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.sentiment_very_dissatisfied,
                      size: 100,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Oh no! Leaving so soon?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We will miss you! Come back soon!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGray.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryOrange,
                ),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
