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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with SL number and Lock Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // SL label with number
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.orangeGradient,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Chapter ${chapter.number}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              if (chapter.isLocked)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, size: 16, color: Colors.red),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Chapter title
          Text(
            chapter.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Video count
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 16,
                color: Color(0xFF3B9EFF),
              ),
              const SizedBox(width: 6),
              Text(
                '${chapter.videoCount} video${chapter.videoCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B9EFF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Show Videos / Unlock button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      chapter.isLocked
                          ? [const Color(0xFFFF5252), const Color(0xFFD32F2F)]
                          : AppColors.orangeGradient,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (chapter.isLocked
                            ? Colors.red
                            : AppColors.primaryOrange)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (chapter.isLocked) ...[
                    const Icon(Icons.lock_open, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    chapter.isLocked ? 'Unlock Now' : 'Show Videos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
