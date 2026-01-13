import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/chapter_list_item.dart';
import '../screens/myclass_screen.dart';
import '../screens/myvideos_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/payment_screen.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';

class MyChaptersScreen extends StatefulWidget {
  final SubjectData subject;
  final String studentName;
  final Map<String, dynamic>? feeDetails;

  const MyChaptersScreen({
    super.key,
    required this.subject,
    required this.studentName,
    this.feeDetails,
  });

  @override
  State<MyChaptersScreen> createState() => _MyChaptersScreenState();
}

class _MyChaptersScreenState extends State<MyChaptersScreen> {
  String? _profileImageUrl;

  // Dynamic chapters loaded from backend
  List<ChapterData> _chapters = [];
  bool _isLoadingChapters = true;
  String? _chaptersError;
  int _totalChapters = 0;
  int _totalVideos = 0;
  int _totalActivities = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final result = await StudentService.getChapters(widget.subject.id);
    if (result['success'] && mounted) {
      try {
        final body = result['data'];
        Map<String, dynamic> subjectData = {};

        if (body is Map && body.containsKey('data')) {
          subjectData = Map<String, dynamic>.from(body['data']);
        } else if (body is Map) {
          subjectData = Map<String, dynamic>.from(body);
        }

        final List<dynamic> list = subjectData['chapters'] ?? [];

        _chapters =
            list.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              return ChapterData(
                id: item['id']?.toString() ?? '',
                number: index + 1, // Generate sequential number
                title: item['name'] ?? '', // Map 'name' from backend to 'title'
                videoCount:
                    item['videos_count'] ??
                    0, // Using count from updated backend
                isLocked:
                    item['is_locked'] ?? false, // Map is_locked from backend
              );
            }).toList();

        // Calculate totals
        _totalChapters = _chapters.length;
        _totalVideos = _chapters.fold(
          0,
          (sum, chapter) => sum + chapter.videoCount,
        );
        _totalActivities =
            _totalVideos; // As per requirement: total activities == total videos

        if (_chapters.isEmpty) {
          _chaptersError = 'No chapters found for this subject.';
        }

        setState(() {
          _isLoadingChapters = false;
        });
      } catch (e) {
        setState(() {
          _chaptersError = 'Error parsing chapters: $e';
          _isLoadingChapters = false;
        });
      }
    } else {
      setState(() {
        _chaptersError = result['message'] ?? 'Failed to load chapters';
        _isLoadingChapters = false;
      });
    }
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

  void _handleChapterTap(ChapterData chapter) {
    // Check if chapter is locked
    if (chapter.isLocked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentScreen(
                studentName: widget.studentName,
                className:
                    'Class 8', // Could be dynamic if we passed className or feeDetails class_id
                feeId: widget.feeDetails?['id']?.toString() ?? '',
                amount: widget.feeDetails?['amount']?.toString() ?? '0',
                subjectId: widget.subject.id,
                classId: widget.feeDetails?['class_id']?.toString() ?? '',
                qrCodeUrl:
                    widget.feeDetails?['qrimage'] != null
                        ? 'https://schoolwala.info/storage/${widget.feeDetails!['qrimage']}'
                        : null,
              ),
        ),
      );
    } else {
      // Navigate to video lessons screen for unlocked chapters
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MyVideosScreen(
                chapter: chapter,
                subject: widget.subject,
                studentName: widget.studentName,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar - Same style as MyClassScreen
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(
                                    studentName: widget.studentName,
                                  ),
                            ),
                          );
                        },
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
                // Subject Image Section
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                widget.subject.icon,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),

                            const Spacer(),

                            // Subject name
                            Text(
                              widget.subject.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Description
                            Text(
                              widget.subject.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 16),

                            // Stats row
                            Row(
                              children: [
                                _buildStatCard(
                                  _isLoadingChapters ? '-' : '$_totalChapters',
                                  'Chapters',
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  _isLoadingChapters ? '-' : '$_totalVideos',
                                  'Videos',
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  _isLoadingChapters
                                      ? '-'
                                      : '$_totalActivities',
                                  'Activities',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Chapters section
                Container(
                  color: const Color(0xFFF8F9FA),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Chapters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: AppColors.textGray.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Class 8',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Chapters list loading logic
                      _buildChapterContent(),
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

  Widget _buildChapterContent() {
    if (_isLoadingChapters) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_chaptersError != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text(_chaptersError!)),
      );
    }
    if (_chapters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('No chapters available')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ChapterListItem(
            chapter: _chapters[index],
            color: widget.subject.colors[0],
            onTap: () => _handleChapterTap(_chapters[index]),
          ),
        );
      },
    );
  }

  // ... existing stat card ...

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chapter data model
class ChapterData {
  final String id;
  final int number;
  final String title;
  final int videoCount;
  final bool isLocked;

  ChapterData({
    this.id = '',
    required this.number,
    required this.title,
    required this.videoCount,
    this.isLocked = false,
  });
}
