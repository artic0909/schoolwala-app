import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants/app_constants.dart';
import '../screens/myvideos_screen.dart';
import '../services/student_service.dart';
import '../widgets/global_bottom_bar.dart';

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
  bool _isLoading = true;

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
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading video details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const GlobalBottomBar(currentIndex: 2),
        );
      },
    );
  }
}
