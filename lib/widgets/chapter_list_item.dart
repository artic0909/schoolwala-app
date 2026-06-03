import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/mychapters_screen.dart';

class ChapterListItem extends StatelessWidget {
  final ChapterData chapter;
  final Color color;
  final VoidCallback onTap;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chapter.isLocked
                ? Colors.red.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (chapter.isLocked ? Colors.red : color).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chapter Number Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: chapter.isLocked
                      ? [
                          Colors.red.withValues(alpha: 0.2),
                          Colors.red.withValues(alpha: 0.05)
                        ]
                      : [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.05)
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: chapter.isLocked ? Colors.red : color,
                    ),
                  ),
                  Text(
                    '${chapter.number}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: chapter.isLocked ? Colors.red : color,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle Content (Title and Videos)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 14,
                        color: AppColors.textGray.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${chapter.videoCount} video${chapter.videoCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGray.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Right Action Button
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: chapter.isLocked
                    ? Colors.red.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                chapter.isLocked ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded,
                size: chapter.isLocked ? 20 : 16,
                color: chapter.isLocked ? Colors.red : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
