import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class LogoutAnimationScreen extends StatefulWidget {
  const LogoutAnimationScreen({super.key});

  @override
  State<LogoutAnimationScreen> createState() => _LogoutAnimationScreenState();
}

class _LogoutAnimationScreenState extends State<LogoutAnimationScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect after 8 seconds (to allow gif to play multiple times)
    Timer(const Duration(seconds: 8), () {
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen GIF
          Positioned.fill(
            child: Image.asset(
              'assets/images/logoutgif.gif',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.sentiment_very_dissatisfied,
                    size: 100,
                    color: Colors.orange,
                  ),
                );
              },
            ),
          ),
          // Gradient Overlay to make text readable
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Oh no! Leaving so soon?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We will miss you! Come back soon!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
