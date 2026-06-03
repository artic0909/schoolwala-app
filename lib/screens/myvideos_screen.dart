import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../screens/mychapters_screen.dart';
import '../screens/myclass_screen.dart';
import '../screens/playvideo_screen.dart';
import '../screens/practice_test_screen.dart';
import '../services/student_service.dart';
import '../widgets/global_bottom_bar.dart';
import '../widgets/app_drawer.dart';
import '../utils/toast_helper.dart';

class MyVideosScreen extends StatefulWidget {
  final ChapterData chapter;
  final SubjectData subject;
  final String studentName;

  const MyVideosScreen({
    super.key,
    required this.chapter,
    required this.subject,
    required this.studentName,
  });

  @override
  State<MyVideosScreen> createState() => _MyVideosScreenState();
}

class _MyVideosScreenState extends State<MyVideosScreen> {
  // Dynamic videos loaded from backend
  List<VideoData> _videos = [];
  bool _isLoadingVideos = true;
  String? _videosError;

  // Chapter info from backend
  String _chapterName = '';
  bool _isFirstChapter = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final result = await StudentService.getVideos(widget.chapter.id);

    if (result['success'] && mounted) {
      try {
        final body = result['data'];
        Map<String, dynamic> videoData = {};

        if (body is Map && body.containsKey('data')) {
          videoData = Map<String, dynamic>.from(body['data']);
        } else if (body is Map) {
          videoData = Map<String, dynamic>.from(body);
        }

        // Extract chapter info
        final chapterInfo = videoData['chapter'];
        if (chapterInfo != null) {
          _chapterName = chapterInfo['chapter_name'] ?? widget.chapter.title;
        }

        _isFirstChapter = videoData['is_first_chapter'] ?? false;

        // Extract videos
        final List<dynamic> list = videoData['videos'] ?? [];

        _videos =
            list.map((item) {
              String thumbnailUrl = 'assets/images/thumbnail.jpg';
              if (item['video_thumbnail'] != null &&
                  item['video_thumbnail'].toString().isNotEmpty) {
                // Check if it's already a full URL or needs the storage path
                if (item['video_thumbnail'].toString().startsWith('http')) {
                  thumbnailUrl = item['video_thumbnail'];
                } else {
                  thumbnailUrl =
                      'https://schoolwala.info/storage/${item['video_thumbnail']}';
                }
              }

              return VideoData(
                id: item['id']?.toString() ?? '',
                title: item['video_title'] ?? 'Untitled Video',
                description:
                    item['video_description'] ?? 'No description available.',
                thumbnailPath: thumbnailUrl,
                duration: item['duration'] ?? '10:00',
                noteUrl: item['note_link'],
                hasPracticeTest: item['has_practice_test'] ?? false,
                hasSubmittedTest: item['has_submitted_test'] ?? false,
                videoUrl: item['video_link'] ?? '',
                likes: item['likes'] ?? 0,
                views: item['views']?.toString() ?? '0',
                isLiked:
                    false, // You might need an API field 'is_liked' if available
              );
            }).toList();

        if (_videos.isEmpty) {
          _videosError = 'No videos found for this chapter.';
        }

        setState(() {
          _isLoadingVideos = false;
        });
      } catch (e) {
        setState(() {
          _videosError = 'Error parsing videos: $e';
          _isLoadingVideos = false;
        });
      }
    } else {
      setState(() {
        // Check if it's a 403 error (locked chapter)
        if (result['status'] == 403) {
          _videosError =
              result['message'] ??
              'This chapter is locked. Please subscribe to access.';
        } else {
          _videosError = result['message'] ?? 'Failed to load videos';
        }
        _isLoadingVideos = false;
      });
    }
  }

  Future<void> _handleDownloadNotes(VideoData video) async {
    final String? noteUrl = video.noteUrl;
    if (noteUrl == null || noteUrl.isEmpty) {
      ToastHelper.showError(context, 'No notes available for this video.');
      return;
    }

    final Uri uri = Uri.parse(noteUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ToastHelper.showError(context, 'Could not launch notes link: $noteUrl');
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Error launching link: $e');
      }
    }
  }

  void _handlePracticeTest(VideoData video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PracticeTestScreen(videoId: video.id, videoTitle: video.title),
      ),
    );
  }

  void _handleVideoTap(VideoData video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PlayVideoScreen(video: video, videoUrl: video.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Sticky Subject Header and Stats Panel
          SliverAppBar(
            pinned: true,
            expandedHeight: 310.0,
            toolbarHeight: 0.0,
            backgroundColor: const Color(0xFFF8F9FA),
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(color: const Color(0xFFF8F9FA)),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.subject.colors[0].withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: widget.subject.backgroundImageUrl != null
                                  ? Image.network(
                                      widget.subject.backgroundImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          widget.subject.imagePath,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      widget.subject.imagePath,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                    stops: const [0.0, 0.3, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: MediaQuery.of(context).padding.top + 20,
                                bottom: 130,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: widget.subject.backgroundImageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.network(
                                              widget.subject.backgroundImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                widget.subject.icon,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            widget.subject.icon,
                                            size: 32,
                                            color: Colors.white,
                                          ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _chapterName.isNotEmpty ? _chapterName : widget.chapter.title,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110.0),
              child: Container(
                height: 110,
                padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 20),
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        _isLoadingVideos ? '-' : '${_videos.length}',
                        'Video Lessons',
                        Icons.play_circle_filled_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildStatCard(
                        _isLoadingVideos
                            ? '-'
                            : '${_videos.where((v) => v.hasPracticeTest).length}',
                        'Practice Activities',
                        Icons.local_activity_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (_isFirstChapter)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primaryOrange, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'This is a FREE preview chapter. Subscribe to unlock all chapters!',
                            style: TextStyle(
                              color: AppColors.darkNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Video Lessons Section
                Container(
                  color: const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Video Lessons',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildVideoList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'My Classes'),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 1),
    );
  }

  Widget _buildVideoList() {
    if (_isLoadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_videosError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.textGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _videosError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      );
    }
    if (_videos.isEmpty) {
      return const Center(child: Text('No videos available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildVideoCard(_videos[index]),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: widget.subject.colors[0],
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoData video) {
    return GestureDetector(
      onTap: () => _handleVideoTap(video),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child:
                        video.thumbnailPath.isNotEmpty
                            ? Image.network(
                              video.thumbnailPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildThumbnailPlaceholder();
                              },
                            )
                            : _buildThumbnailPlaceholder(),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Color(0xFF3B9EFF),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGray.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (video.noteUrl != null && video.noteUrl!.isNotEmpty)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleDownloadNotes(video),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B9EFF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B9EFF,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download_outlined,
                                    size: 18,
                                    color: Color(0xFF3B9EFF),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B9EFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (video.noteUrl != null &&
                          video.noteUrl!.isNotEmpty &&
                          video.hasPracticeTest)
                        const SizedBox(width: 12),
                      if (video.hasPracticeTest)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handlePracticeTest(video),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    video.hasSubmittedTest
                                        ? const Color(0xFFFFC107).withValues(alpha: 
                                          0.1,
                                        ) // Yellow tint
                                        : const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.1), // Green tint
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      video.hasSubmittedTest
                                          ? const Color(0xFFFFC107) // Yellow
                                          : const Color(0xFF4CAF50), // Green
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    video.hasSubmittedTest
                                        ? Icons.emoji_events_outlined
                                        : Icons.edit_outlined,
                                    size: 18,
                                    color:
                                        video.hasSubmittedTest
                                            ? const Color(
                                              0xFFFFB300,
                                            ) // Darker yellow for visibility
                                            : const Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    video.hasSubmittedTest
                                        ? 'Show Result'
                                        : 'Practice',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          video.hasSubmittedTest
                                              ? const Color(0xFFFFB300)
                                              : const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF3B9EFF), const Color(0xFF2196F3)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 60, color: Colors.white),
      ),
    );
  }
}

class VideoData {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final String duration;
  final String? noteUrl;
  final bool hasPracticeTest;
  final bool hasSubmittedTest;
  final String videoUrl;
  final int likes;
  final String views;
  final bool isLiked;

  VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.duration,
    this.noteUrl,
    required this.hasPracticeTest,
    this.hasSubmittedTest = false,
    required this.videoUrl,
    this.likes = 0,
    this.views = '0',
    this.isLiked = false,
  });
}
