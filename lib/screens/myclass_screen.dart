import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/subject_card.dart';
import '../widgets/curriculum_card.dart';
import '../widgets/feature_card.dart';
import '../screens/mychapters_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';

class MyClassScreen extends StatefulWidget {
  final String studentName;

  const MyClassScreen({super.key, required this.studentName});

  @override
  State<MyClassScreen> createState() => _MyClassScreenState();
}

class _MyClassScreenState extends State<MyClassScreen> {
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
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

  // Sample subjects data - will be dynamic later
  final List<SubjectData> subjects = [
    SubjectData(
      name: 'সাহিত্যমালা',
      englishName: 'Sahityamala',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.translate,
      imagePath: 'assets/images/1.jpeg',
      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
    ),
    SubjectData(
      name: 'BLOSSOM',
      englishName: 'Blossom',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.book,
      imagePath: 'assets/images/2.jpeg',
      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    ),
    SubjectData(
      name: 'গণিতগুঞ্জ',
      englishName: 'Ganitgunja',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.calculate,
      imagePath: 'assets/images/3.jpeg',
      colors: [Color(0xFF5F27CD), Color(0xFF341F97)],
    ),
    SubjectData(
      name: 'Science',
      englishName: 'Science',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.science,
      imagePath: 'assets/images/4.jpeg',
      colors: [Color(0xFF00B894), Color(0xFF00A885)],
    ),
    SubjectData(
      name: 'English',
      englishName: 'English',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.abc,
      imagePath: 'assets/images/5.jpeg',
      colors: [Color(0xFF0984E3), Color(0xFF0652DD)],
    ),
    SubjectData(
      name: 'Social Studies',
      englishName: 'Social Studies',
      description:
          'Build strong foundation in concepts with interactive problems and visual learning.',
      icon: Icons.public,
      imagePath: 'assets/images/6.jpeg',
      colors: [Color(0xFFFD79A8), Color(0xFFE84393)],
    ),
  ];

  final List<CurriculumFeature> curriculumFeatures = [
    CurriculumFeature(
      icon: '📊',
      title: 'Structured Learning Path',
      description:
          'Our curriculum is divided into levels and modules that progressively build concepts from basic to advanced.',
    ),
    CurriculumFeature(
      icon: '🎬',
      title: 'Animated Video Lessons',
      description:
          'Complex concepts broken down into bite-sized, engaging animated videos for better understanding.',
    ),
    CurriculumFeature(
      icon: '🧩',
      title: 'Practice & Assessments',
      description:
          'Regular practice problems and assessments to reinforce learning and track progress.',
    ),
  ];

  final List<WhyChooseFeature> whyChooseFeatures = [
    WhyChooseFeature(
      icon: Icons.school,
      title: 'Expert Educators',
      description:
          'Content created by subject matter experts with teaching experience.',
      color: Color(0xFFFFB74D),
      imagePath: 'assets/images/1.jpeg',
    ),
    WhyChooseFeature(
      icon: Icons.phone_android,
      title: 'Learn Anywhere',
      description:
          'Access courses on mobile, tablet, or desktop at your convenience.',
      color: Color(0xFFFFB74D),
      imagePath: 'assets/images/3.jpeg',
    ),
    WhyChooseFeature(
      icon: Icons.videogame_asset,
      title: 'Gamified Learning',
      description:
          'Interactive games and quizzes to make learning fun and engaging.',
      color: Color(0xFFFFB74D),
      imagePath: 'assets/images/5.jpeg',
    ),
    WhyChooseFeature(
      icon: Icons.trending_up,
      title: 'Progress Tracking',
      description:
          'Detailed reports to track your child\'s progress and performance.',
      color: Color(0xFFFFB74D),
      imagePath: 'assets/images/7.jpeg',
    ),
  ];

  void _handleSubjectTap(SubjectData subject) {
    // Navigate to MyChaptersScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MyChaptersScreen(
              subject: subject,
              studentName: widget.studentName,
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
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 80,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Student',
                            style: TextStyle(
                              fontSize: 12,
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
                const SizedBox(height: 30),

                // Main heading
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'Designed for Every Student',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Comprehensive curriculum aligned with WBBSE, CBSE, ICSE, and State Boards.\nEngaging content designed to make learning fun and effective.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Class selector button
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.orangeGradient,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Class 8',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Subjects section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Subjects We Cover',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Subjects grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth > 900
                              ? 3
                              : constraints.maxWidth > 600
                              ? 2
                              : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          return SubjectCard(
                            subject: subjects[index],
                            onTap: () => _handleSubjectTap(subjects[index]),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 80),

                // How Our Curriculum Works section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Text(
                        'How Our Curriculum Works',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Our structured approach ensures students build strong foundations and\ndevelop critical thinking skills',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGray.withOpacity(0.9),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth > 900
                                    ? 3
                                    : constraints.maxWidth > 600
                                    ? 2
                                    : 1;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.3,
                                  ),
                              itemCount: curriculumFeatures.length,
                              itemBuilder: (context, index) {
                                return CurriculumCard(
                                  feature: curriculumFeatures[index],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Why Choose Schoolwala section
                Column(
                  children: [
                    const Text(
                      'Why Choose Schoolwala?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 900
                                  ? 4
                                  : constraints.maxWidth > 600
                                  ? 2
                                  : 1;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: whyChooseFeatures.length,
                            itemBuilder: (context, index) {
                              return FeatureCard(
                                feature: whyChooseFeatures[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
class SubjectData {
  final String name;
  final String englishName;
  final String description;
  final IconData icon;
  final String imagePath;
  final List<Color> colors;

  SubjectData({
    required this.name,
    required this.englishName,
    required this.description,
    required this.icon,
    required this.imagePath,
    required this.colors,
  });
}

class CurriculumFeature {
  final String icon;
  final String title;
  final String description;

  CurriculumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class WhyChooseFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String imagePath;

  WhyChooseFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.imagePath,
  });
}
