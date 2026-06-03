import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/chapter_list_item.dart';
import '../screens/myclass_screen.dart';
import '../screens/myvideos_screen.dart';
import '../screens/payment_screen.dart';
import '../services/student_service.dart';
import '../widgets/global_bottom_bar.dart';
import '../widgets/app_drawer.dart';

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
  String? _className;

  // Dynamic chapters loaded from backend
  List<ChapterData> _chapters = [];
  bool _isLoadingChapters = true;
  String? _chaptersError;
  int _totalChapters = 0;
  int _totalVideos = 0;
  int _totalActivities = 0;

  // Payment/Fee details
  Map<String, dynamic>? _feeDetails;
  bool _hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    _feeDetails = widget.feeDetails;
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

        // Get subscription status
        _hasActiveSubscription = subjectData['has_subscription'] ?? false;

        _chapters =
            list.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              return ChapterData(
                id: item['id']?.toString() ?? '',
                number: item['chapter_index'] ?? (index + 1),
                title:
                    (item['chapter_name'] != null &&
                            item['chapter_name'].toString().isNotEmpty)
                        ? item['chapter_name']
                        : 'Chapter ${item['chapter_index'] ?? (index + 1)}',
                videoCount: item['videos_count'] ?? 0,
                isLocked: item['is_locked'] ?? false,
              );
            }).toList();

        // Calculate totals
        _totalChapters = subjectData['total_chapters'] ?? _chapters.length;
        _totalVideos = _chapters.fold(
          0,
          (sum, chapter) => sum + chapter.videoCount,
        );
        _totalActivities = _totalVideos;

        if (_chapters.isEmpty) {
          _chaptersError = 'No chapters found for this subject.';
        }

        setState(() {
          _isLoadingChapters = false;
        });

        // Load payment info if not subscribed and we don't have it yet
        if (!_hasActiveSubscription && _feeDetails == null) {
          _loadPaymentInfo();
        }
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

  Future<void> _loadPaymentInfo() async {
    final result = await StudentService.getPaymentInfo();
    if (result['success'] && mounted) {
      try {
        final body = result['data'];
        Map<String, dynamic> paymentData = {};

        if (body is Map && body.containsKey('data')) {
          paymentData = Map<String, dynamic>.from(body['data']);
        } else if (body is Map) {
          paymentData = Map<String, dynamic>.from(body);
        }

        final classData = paymentData['class'];
        final feesData = paymentData['fees'];

        if (classData != null) {
          _className = classData['class_name'] ?? 'Class';
        }

        if (feesData != null) {
          setState(() {
            _feeDetails = {
              'id': feesData['id'],
              'class_id': feesData['class_id'],
              'amount': feesData['amount']?.toString() ?? '0',
              'qrimage': feesData['qrimage'],
            };
          });
        }
      } catch (e) {
        debugPrint('Error loading payment info: $e');
      }
    }
  }

  void _handleChapterTap(ChapterData chapter) {
    if (chapter.isLocked) {
      // Show payment screen if chapter is locked
      if (_feeDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PaymentScreen(
                  studentName: widget.studentName,
                  className: _className ?? 'Class',
                  feeId: _feeDetails!['id']?.toString() ?? '',
                  amount: _feeDetails!['amount']?.toString() ?? '0',
                  subjectId: widget.subject.id,
                  classId: _feeDetails!['class_id']?.toString() ?? '',
                  qrCodeUrl:
                      _feeDetails!['qrimage'] != null
                          ? 'https://schoolwala.info/storage/${_feeDetails!['qrimage']}'
                          : null,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment information not available. Please try again.',
            ),
          ),
        );
      }
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
          // Sticky Subject Header and Stats Panel
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0, // Image height minus overlap
            toolbarHeight: 0.0,
            backgroundColor: const Color(0xFFF8F9FA), // Covers notch when pinned
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Solid background for the whole expanded area
                  Positioned.fill(
                    child: Container(color: const Color(0xFFF8F9FA)),
                  ),
                  // The Curved Image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 320, // Extends down to overlap with stats panel
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
                                      Colors.black.withValues(alpha: 0.4), // Top shadow for back button
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
                                top: MediaQuery.of(context).padding.top + 40,
                                bottom: 50,
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
                                    widget.subject.name,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.subject.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.4,
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
                  // Back Button Overlay
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
                        _isLoadingChapters ? '-' : '$_totalChapters',
                        'Chapters',
                        Icons.menu_book_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildStatCard(
                        _isLoadingChapters ? '-' : '$_totalVideos',
                        'Videos',
                        Icons.play_circle_filled_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildStatCard(
                        _isLoadingChapters ? '-' : '$_totalActivities',
                        'Activities',
                        Icons.local_activity_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Chapters Section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course Content',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.school,
                              size: 14,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _className ?? 'Class',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildChapterContent(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'My Classes'),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 1),
    );
  }

  Widget _buildChapterContent() {
    if (_isLoadingChapters) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      );
    }
    if (_chaptersError != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text(_chaptersError!, style: const TextStyle(color: Colors.red))),
      );
    }
    if (_chapters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('No chapters available', style: TextStyle(color: AppColors.textGray))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ChapterListItem(
            chapter: _chapters[index],
            color: widget.subject.colors[0],
            onTap: () => _handleChapterTap(_chapters[index]),
          ),
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
}

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

