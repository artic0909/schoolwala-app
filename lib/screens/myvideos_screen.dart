import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/mychapters_screen.dart';
import '../screens/myclass_screen.dart';
import '../screens/playvideo_screen.dart';
import '../screens/practice_test_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';

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
  String? _profileImageUrl;

  // Dynamic videos loaded from backend
  List<VideoData> _videos = [];
  bool _isLoadingVideos = true;
  String? _videosError;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadVideos();
  }

  Future<void> _loadProfileImage() async {
    final result = await AuthService.getProfile();
    if (result['success'] && mounted) {
      final profile = result['data']['profile'];
      if (profile['profile_image'] != null) {
        setState(() {
          _profileImageUrl =
              'https://schoolwala.info/storage/${profile['profile_image']}';
        });
      }
    }
  }

  Future<void> _loadVideos() async {
    final result = await StudentService.getVideos(widget.chapter.id);
    if (result['success'] && mounted) {
      try {
        final data = result['data'];
        final List<dynamic> list = data['videos'] ?? [];

        _videos =
            list.map((item) {
              String thumbnail = 'assets/images/thumbnail.jpg';
              if (item['video_thumbnail'] != null) {
                thumbnail =
                    'https://schoolwala.info/storage/${item['video_thumbnail']}';
              }

              return VideoData(
                id: item['id']?.toString() ?? '',
                title: item['video_title'] ?? 'Untitled Video',
                description:
                    item['video_description'] ?? 'No description available.',
                thumbnailPath: thumbnail,
                duration: item['duration'] ?? '10:00',
                hasNotes: item['has_notes'] ?? false,
                hasPracticeTest: item['has_practice_test'] ?? false,
                videoUrl: item['video_link'] ?? '',
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
        _videosError = result['message'] ?? 'Failed to load videos';
        _isLoadingVideos = false;
      });
    }
  }

  void _handleProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(studentName: widget.studentName),
      ),
    );
  }

  void _handleDownloadNotes(VideoData video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading notes for: ${video.title}'),
        backgroundColor: const Color(0xFF3B9EFF),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handlePracticeTest(VideoData video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PracticeTestScreen()),
    );
  }

  void _handleVideoTap(VideoData video) {
    // Navigate to video player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PlayVideoScreen(
              video: video,
              videoUrl:
                  video.videoUrl.isNotEmpty
                      ? video.videoUrl
                      : 'https://www.youtube.com/embed/k0NMKKLGUHw?si=rHvRyrut5n3nmnf7',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar - Same style as MyChaptersScreen
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
                      const SizedBox(width: 40), // Space for back button
                      // Logo with gradient background
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

                      // Student name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.studentName,
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
                      ),

                      const SizedBox(width: 12),

                      // Profile button
                      GestureDetector(
                        onTap: _handleProfileTap,
                        child: Container(
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
                                  _profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!)
                                          as ImageProvider
                                      : const AssetImage(
                                        'assets/images/profile.jpg',
                                      ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
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
                      // Background image
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

                      // Dark overlay
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

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
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

                            // Chapter title
                            Text(
                              widget.chapter.title,
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

                            // Description
                            const Text(
                              'Embark on a numerical adventure! Learn how to handle big numbers, compare them, and use them in real-life situations.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const Spacer(),

                            // Stats row
                            Row(
                              children: [
                                _buildStatCard(
                                  _isLoadingVideos ? '-' : '${_videos.length}',
                                  'Run Video Lessons',
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
                      // Section header
                      const Text(
                        'Video Lessons',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Videos list loading logic
                      _buildVideoList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    if (_isLoadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_videosError != null) {
      return Center(child: Text(_videosError!));
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF3B9EFF),
                            const Color(0xFF2196F3),
                          ],
                        ),
                      ),
                      child: Image.asset(
                        video.thumbnailPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Play button overlay
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
                // Duration badge
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
                  // Title
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

                  // Description
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

                  // Action buttons
                  Row(
                    children: [
                      // Download Notes button
                      if (video.hasNotes)
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

                      if (video.hasNotes && video.hasPracticeTest)
                        const SizedBox(width: 12),

                      // Practice Test button
                      if (video.hasPracticeTest)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handlePracticeTest(video),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Practice',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4CAF50),
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
}

// Video data model
class VideoData {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final String duration;
  final bool hasNotes;
  final bool hasPracticeTest;
  final String videoUrl;

  VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.duration,
    required this.hasNotes,
    required this.hasPracticeTest,
    required this.videoUrl,
  });
}
