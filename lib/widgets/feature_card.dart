import 'package:flutter/material.dart';
import '../screens/myclass_screen.dart';

class FeatureCard extends StatelessWidget {
  final WhyChooseFeature feature;

  const FeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              feature.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: feature.color.withOpacity(0.1));
              },
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(feature.icon, size: 32, color: Colors.white),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
