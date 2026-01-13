import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants/app_constants.dart';
import '../screens/myvideos_screen.dart';
import '../services/student_service.dart';

class PlayVideoScreen extends StatefulWidget {
  final VideoData video;
  final String videoUrl;

  const PlayVideoScreen({
    super.key,
    required this.video,
    required this.videoUrl,
  });

  @override
  State<PlayVideoScreen> createState() => _PlayVideoScreenState();
}

class _PlayVideoScreenState extends State<PlayVideoScreen> {
  late YoutubePlayerController _controller;
  String? _videoId;
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.videoUrl);
    debugPrint(
      'PlayVideoScreen: URL: ${widget.videoUrl}, Extracted ID: $_videoId',
    );

    if (_videoId != null && _videoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
    }
  }

  String? _extractVideoId(String url) {
    // 1. Try standard extractor first
    String? id = YoutubePlayer.convertUrlToId(url);
    if (id != null && id.isNotEmpty) return id;

    // 2. Custom extraction for embed links
    try {
      if (url.contains('/embed/')) {
        final parts = url.split('/embed/');
        if (parts.length > 1) {
          final idPart = parts[1];
          // Remove query parameters
          final cleanId = idPart.split('?').first;
          if (cleanId.isNotEmpty) return cleanId;
        }
      }
    } catch (e) {
      debugPrint('Error extracting video ID: $e');
    }

    // 3. Fallback: return empty string if nothing found (handled by player error)
    return null;
  }

  @override
  void dispose() {
    if (_videoId != null && _videoId!.isNotEmpty) {
      _controller.dispose();
    }
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
    });

    final result = await StudentService.likeVideo(widget.video.id);

    if (result['success']) {
      // Keep optimistic update or update with server count if returned
    } else {
      // Revert if failed
      setState(() {
        _isLiked = !_isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update like'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDownloadNotes() async {
    if (widget.video.noteUrl == null || widget.video.noteUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notes available for this video')),
      );
      return;
    }

    final url = widget.video.noteUrl!;
    // TODO: Use url_launcher to open the link
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // }

    debugPrint('Opening notes: $url');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening notes: $url'),
        backgroundColor: const Color(0xFF3B9EFF),
      ),
    );
  }

  Future<void> _handleSubmitFeedback() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await StudentService.submitFeedback(
      widget.video.id,
      _feedbackController
          .text, // You might need to send rating too if API supports it
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _selectedRating = 0;
        _feedbackController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit feedback'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primaryOrange,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primaryOrange,
          handleColor: AppColors.primaryOrange,
        ),
        onReady: () {
          _controller.addListener(() {});
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Video Player',
              style: TextStyle(
                color: AppColors.darkNavy,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // YouTube Player
                player,

                // Video Information Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Title
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Video Stats
                      Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: AppColors.textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.video.views} views',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.thumb_up_outlined,
                            size: 16,
                            color: AppColors.textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.video.likes} likes',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.video.duration,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          // Like Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _handleLike,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _isLiked
                                          ? AppColors.primaryOrange
                                          : AppColors.primaryOrange.withOpacity(
                                            0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryOrange,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                      color:
                                          _isLiked
                                              ? Colors.white
                                              : AppColors.primaryOrange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Like this video',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _isLiked
                                                ? Colors.white
                                                : AppColors.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Only show note download if available
                      if (widget.video.noteUrl != null &&
                          widget.video.noteUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: _handleDownloadNotes,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B9EFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF3B9EFF),
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download_outlined,
                                    size: 20,
                                    color: Color(0xFF3B9EFF),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Download Notes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B9EFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Feedback Section
                      const Text(
                        'Your Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rating Question
                      const Text(
                        'How much did you enjoy this video?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkNavy,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Star Rating
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                index < _selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 36,
                                color:
                                    index < _selectedRating
                                        ? AppColors.primaryOrange
                                        : AppColors.textGray.withOpacity(0.4),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Feedback Text Question
                      const Text(
                        'What did you think of this video?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkNavy,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Feedback Text Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText:
                                'Your thoughts, questions, or suggestions...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGray,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Submit Button
                      GestureDetector(
                        onTap: _handleSubmitFeedback,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: AppColors.orangeGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Submit Feedback',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
