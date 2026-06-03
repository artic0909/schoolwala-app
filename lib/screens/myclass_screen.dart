import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/subject_card.dart';
import '../screens/mychapters_screen.dart';
import '../services/auth_service.dart';
import '../services/student_service.dart';
import '../widgets/global_bottom_bar.dart';
import '../widgets/app_drawer.dart';

class MyClassScreen extends StatefulWidget {
  final String studentName;

  const MyClassScreen({super.key, required this.studentName});

  @override
  State<MyClassScreen> createState() => _MyClassScreenState();
}

class _MyClassScreenState extends State<MyClassScreen> {
  // Dynamic subjects loaded from backend
  List<SubjectData> _subjects = [];
  bool _isLoadingSubjects = true;
  String? _subjectsError;
  String _className = '';
  Map<String, dynamic>? _feeDetails;

  String _getGreeting() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final hour = now.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final result = await StudentService.getMyClass();
    if (result['success'] && mounted) {
      try {
        final data = result['data'];
        List<dynamic> list = [];
        List<dynamic> fees = [];

        if (data is Map) {
          if (data.containsKey('name')) {
            _className = data['name']?.toString() ?? '';
          }
          if (data.containsKey('fees')) {
            fees = data['fees'] ?? [];
          }

          if (data.containsKey('subjects')) {
            list = data['subjects'] ?? [];
          } else if (data.containsKey('data') &&
              data['data'] is Map &&
              data['data'].containsKey('subjects')) {
            // Handle if data is nested inside another data key
            if (data['data'].containsKey('name')) {
              _className = data['data']['name']?.toString() ?? '';
            }
            if (data['data'].containsKey('fees')) {
              fees = data['data']['fees'] ?? [];
            }
            list = data['data']['subjects'] ?? [];
          } else if (data.containsKey('data') && data['data'] is List) {
            list = data['data'];
          }
        } else if (data is List) {
          list = data;
        }

        if (fees.isNotEmpty) {
          _feeDetails = fees[0];
        }

        // Predefined fallback assets for round-robin assignment
        final List<String> fallbackImages = [
          'assets/images/1.jpeg',
          'assets/images/2.jpeg',
          'assets/images/3.jpeg',
          'assets/images/4.jpeg',
          'assets/images/5.jpeg',
          'assets/images/6.jpeg',
        ];

        final List<List<Color>> fallbackColors = [
          [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
          [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          [Color(0xFF5F27CD), Color(0xFF341F97)],
          [Color(0xFF00B894), Color(0xFF00A885)],
          [Color(0xFF0984E3), Color(0xFF0652DD)],
          [Color(0xFFFD79A8), Color(0xFFE84393)],
        ];

        final List<IconData> fallbackIcons = [
          Icons.translate,
          Icons.book,
          Icons.calculate,
          Icons.science,
          Icons.abc,
          Icons.public,
        ];

        _subjects =
            list.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              // Use modulo to cycle through local assets
              int assetIndex = index % fallbackImages.length;

              // Handle background image
              String? bgImage = item['background_image'];
              String? backgroundImageUrl;
              if (bgImage != null && bgImage.toString().isNotEmpty) {
                backgroundImageUrl = 'https://schoolwala.info/storage/$bgImage';
              }

              return SubjectData(
                id: item['id']?.toString() ?? '',
                name: item['name'] ?? '',
                englishName:
                    item['name'] ??
                    '', // Fallback to name as english_name is missing
                description:
                    'Build strong foundation in concepts with interactive problems and visual learning.', // Fixed description
                icon: fallbackIcons[assetIndex],
                imagePath: fallbackImages[assetIndex], // Use local asset
                colors: fallbackColors[assetIndex],
                backgroundImageUrl: backgroundImageUrl,
              );
            }).toList();

        if (_subjects.isEmpty) {
          _subjectsError = 'No subjects found for your class.';
        }

        setState(() {
          _isLoadingSubjects = false;
        });
      } catch (e) {
        setState(() {
          _subjectsError = 'Error loading subjects: $e';
          _isLoadingSubjects = false;
        });
      }
    } else {
      setState(() {
        _subjectsError = result['message'] ?? 'Failed to load subjects';
        _isLoadingSubjects = false;
      });
    }
  }

  void _handleSubjectTap(SubjectData subject) {
    // Navigate to MyChaptersScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MyChaptersScreen(
              subject: subject,
              studentName: widget.studentName,
              feeDetails: _feeDetails,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: AppDrawer(studentName: widget.studentName),
      body: Column(
        children: [
          // --- FIXED HEADER ---
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Top Header (Curved Background)
              Container(
                height: 230,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        // Schoolwala Logo Text or Image
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              const Text(
                                'SCHOOLWALA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Education For All | WBBSE & CBSE',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Overlapping Profile Card
              Positioned(
                top: 130,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: AuthService.userNotifier,
                        builder: (context, userData, _) {
                          final profile = userData?['profile'] ?? userData;
                          final profileImage = (profile is Map) ? profile['profile_image'] : null;
                          final profileImageUrl = profileImage != null
                              ? 'https://schoolwala.info/storage/$profileImage'
                              : null;
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: DecorationImage(
                                image: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl) as ImageProvider
                                    : const AssetImage('assets/images/profile.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Greeting and School
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<Map<String, dynamic>?>(
                              valueListenable: AuthService.userNotifier,
                              builder: (context, userData, _) {
                                final student = userData?['student'] ?? userData;
                                final name = (student is Map)
                                    ? (student['student_name'] ?? widget.studentName)
                                    : widget.studentName;
                                final studentId = (student is Map)
                                    ? (student['student_id'] ?? 'N/A')
                                    : 'N/A';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_getGreeting()} 👋',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGray.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkNavy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.class_, size: 12, color: Colors.blue),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${_className.isNotEmpty ? _className : 'Class'} | ID: $studentId',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkNavy,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50), // Spacer for the overlapping card

          // --- SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Quick Access Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quick Subjects Access',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                  ),

                  // Subjects Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_isLoadingSubjects) {
                          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                        }
                        if (_subjectsError != null) {
                          return Center(child: Text(_subjectsError!));
                        }
                        if (_subjects.isEmpty) {
                          return const Center(child: Text('No subjects available'));
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _subjects.length, // Show all subjects
                          itemBuilder: (context, index) {
                            return SubjectCard(
                              subject: _subjects[index],
                              onTap: () => _handleSubjectTap(_subjects[index]),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Fee Due Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fee Due',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                        ),
                        Text(
                          'View Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: AppColors.primaryOrange, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tuition Fee (May 2024)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due Date: 20 May 2024',
                                  style: TextStyle(fontSize: 12, color: Colors.red.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '₹2,500',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Pay Now',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 0),
    );
  }
}

// Data models
class SubjectData {
  final String id;
  final String name;
  final String englishName;
  final String description;
  final IconData icon;
  final String imagePath;
  final List<Color> colors;
  final String? backgroundImageUrl;

  SubjectData({
    required this.id,
    required this.name,
    required this.englishName,
    required this.description,
    required this.icon,
    required this.imagePath,
    required this.colors,
    this.backgroundImageUrl,
  });
}
