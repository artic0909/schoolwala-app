import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../screens/mychapters_screen.dart';
import '../screens/myclass_screen.dart';
import '../screens/playvideo_screen.dart';
import '../screens/practice_test_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../widgets/global_bottom_bar.dart';

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
  String _subjectName = '';
  int _chapterIndex = 1;
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
          _subjectName = chapterInfo['subject_name'] ?? widget.subject.name;
        }

        _isFirstChapter = videoData['is_first_chapter'] ?? false;
        _chapterIndex = videoData['chapter_index'] ?? widget.chapter.number;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No notes available for this video.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(noteUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch notes link: $noteUrl'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching link: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 80,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.orangeGradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryOrange.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/logo_bg.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: AuthService.userNotifier,
                        builder: (context, userData, _) {
                          final student = userData?['student'] ?? userData;
                          final name =
                              (student is Map)
                                  ? (student['student_name'] ??
                                      widget.studentName)
                                  : widget.studentName;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Student',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGray.withOpacity(0.8),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(
                                    studentName:
                                        (AuthService
                                                .userNotifier
                                                .value?['student']?['student_name'] ??
                                            widget.studentName),
                                  ),
                            ),
                          );
                        },
                        child: ValueListenableBuilder<Map<String, dynamic>?>(
                          valueListenable: AuthService.userNotifier,
                          builder: (context, userData, _) {
                            final profile = userData?['profile'] ?? userData;
                            final profileImage =
                                (profile is Map)
                                    ? profile['profile_image']
                                    : null;
                            final profileImageUrl =
                                profileImage != null
                                    ? 'https://schoolwala.info/storage/$profileImage'
                                    : null;

                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryOrange,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image:
                                      profileImageUrl != null
                                          ? NetworkImage(profileImageUrl)
                                              as ImageProvider
                                          : const AssetImage(
                                            'assets/images/profile.jpg',
                                          ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
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
                // Chapter Header Section
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          widget.subject.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: widget.subject.colors,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.subject.icon,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _chapterName.isNotEmpty
                                  ? _chapterName
                                  : widget.chapter.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isFirstChapter
                                  ? 'This is a FREE preview chapter. Subscribe to unlock all chapters!'
                                  : 'Explore comprehensive video lessons and practice activities.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                _buildStatCard(
                                  _isLoadingVideos ? '-' : '${_videos.length}',
                                  'Video Lessons',
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  _isLoadingVideos
                                      ? '-'
                                      : '${_videos.where((v) => v.hasPracticeTest).length}',
                                  'Practice Activities',
                                ),
                              ],
                            ),
                          ],
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
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 2),
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
                color: AppColors.textGray.withOpacity(0.5),
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

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
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
              color: Colors.black.withOpacity(0.06),
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
                        color: Colors.white.withOpacity(0.9),
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
                      color: Colors.black.withOpacity(0.7),
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
                      color: AppColors.textGray.withOpacity(0.9),
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
                                color: const Color(0xFF3B9EFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B9EFF,
                                  ).withOpacity(0.3),
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
                                        ? const Color(0xFFFFC107).withOpacity(
                                          0.1,
                                        ) // Yellow tint
                                        : const Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.1), // Green tint
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
