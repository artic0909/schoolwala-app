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
  
  // Feedback state
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmittingFeedback = false;

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
    _loadVideoDetails();
  }

  Future<void> _loadVideoDetails() async {
    try {
      final result = await StudentService.getVideoDetails(widget.video.id);
      if (result['success'] && mounted) {
        // Future updates based on response data
      }
    } catch (e) {
      debugPrint('Error loading video details: $e');
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
          extendBody: true,
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom background image with fade
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/1.jpeg',
                    fit: BoxFit.cover,
                    height: 450,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
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
                              const SizedBox(width: 24),
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

                          const SizedBox(height: 24),
                          
                          // Feedback Section
                          _buildFeedbackSection(),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final result = await StudentService.submitFeedback(
        widget.video.id.toString(),
        _feedbackController.text.trim(),
        _rating,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback submitted successfully!'), backgroundColor: Colors.green),
          );
          setState(() {
            _rating = 0;
            _feedbackController.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to submit feedback'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingFeedback = false;
        });
      }
    }
  }

  Widget _buildFeedbackSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: index < _rating ? Colors.amber : Colors.grey.withValues(alpha: 0.4),
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }).map((e) => Padding(padding: const EdgeInsets.only(right: 6), child: e)).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Your thoughts, questions, or suggestions...',
              hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryOrange),
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSubmittingFeedback ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              icon: _isSubmittingFeedback
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                _isSubmittingFeedback ? 'Sending...' : 'Send',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
