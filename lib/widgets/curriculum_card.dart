import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/myclass_screen.dart';

class CurriculumCard extends StatelessWidget {
  final CurriculumFeature feature;

  const CurriculumCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(feature.icon, style: const TextStyle(fontSize: 32)),
            ),
          ),

          const Spacer(),

          // Title
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGray.withOpacity(0.9),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
