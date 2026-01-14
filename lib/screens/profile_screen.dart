import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/showcase_card.dart';
import 'profile_edit_screen.dart';
import 'logout_animation_screen.dart';
import '../services/auth_service.dart';
import '../widgets/global_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String studentName;

  const ProfileScreen({super.key, required this.studentName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.getProfile();

    if (result['success']) {
      setState(() {
        _profileData = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _getInterests() {
    if (_profileData == null || _profileData!['profile'] == null) {
      return [];
    }

    final interestIn = _profileData!['profile']['interest_in'];
    if (interestIn == null) return [];

    if (interestIn is List) {
      return List<String>.from(interestIn);
    } else if (interestIn is String) {
      try {
        final decoded = interestIn.replaceAll('\\', '');
        final List<dynamic> parsed =
            (decoded.startsWith('['))
                ? List<dynamic>.from(
                  decoded
                      .substring(1, decoded.length - 1)
                      .split(',')
                      .map((e) => e.trim().replaceAll('"', '')),
                )
                : [decoded];
        return List<String>.from(parsed);
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  IconData _getIconForInterest(String interest) {
    final Map<String, IconData> iconMap = {
      'Mathematics': Icons.calculate,
      'Science': Icons.science,
      'Coding': Icons.computer,
      'Hindi': Icons.translate,
      'English': Icons.abc,
      'Art & Drawing': Icons.palette,
      'Reading': Icons.book,
      'Music': Icons.music_note,
      'History': Icons.history_edu,
      'Geography': Icons.public,
      'Physics': Icons.science,
      'Chemistry': Icons.science,
      'Biology': Icons.biotech,
    };
    return iconMap[interest] ?? Icons.star;
  }

  Color _getColorForInterest(int index) {
    final List<Color> colors = [
      Colors.teal,
      Colors.lightBlue,
      Colors.cyan,
      Colors.indigoAccent,
      Colors.purple,
      Colors.pink,
      Colors.orange,
      Colors.green,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            'My Profile',
            style: TextStyle(
              color: AppColors.darkNavy,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    if (_errorMessage != null) {
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
            'My Profile',
            style: TextStyle(
              color: AppColors.darkNavy,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final student = _profileData!['student'];
    final profile = _profileData!['profile'];
    final classDetails = _profileData!['class_details'];
    final interests = _getInterests();

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
          'My Profile',
          style: TextStyle(
            color: AppColors.darkNavy,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // ================= Profile Avatar Section =================
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF9F43),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: AuthService.userNotifier,
                        builder: (context, userData, _) {
                          final currentProfile =
                              userData?['profile'] ?? profile;
                          final profileImagePath =
                              (currentProfile is Map)
                                  ? currentProfile['profile_image']
                                  : null;
                          final profileImageUrl =
                              profileImagePath != null
                                  ? 'https://schoolwala.info/storage/$profileImagePath'
                                  : null;

                          return Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFEAAA93),
                                  width: 3,
                                ),
                                image:
                                    profileImageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(profileImageUrl),
                                          fit: BoxFit.cover,
                                        )
                                        : const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/profile.jpg',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Animated Badges
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 0 + _animation.value,
                                right: 15,
                                child: _buildBadge(
                                  Icons.star,
                                  Colors.pinkAccent,
                                ),
                              ),
                              Positioned(
                                bottom: 0 - _animation.value,
                                right: 20,
                                child: _buildBadge(
                                  Icons.emoji_events,
                                  Colors.green,
                                ),
                              ),
                              Positioned(
                                bottom: 40 + (_animation.value / 2),
                                left: 0,
                                child: _buildBadge(
                                  Icons.lightbulb,
                                  Colors.lightBlue,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Student Name & ID
              Center(
                child: Column(
                  children: [
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: AuthService.userNotifier,
                      builder: (context, userData, _) {
                        final name =
                            userData?['student']?['student_name'] ??
                            student['student_name'] ??
                            'Student';
                        return Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.darkNavy,
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Student ID: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: student['student_id'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Curious learner exploring the world!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Modern Update Profile Button
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ProfileEditScreen(
                                      profileData: _profileData!,
                                    ),
                              ),
                            );
                            if (result == true) {
                              _loadProfile();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Modern Logout Button
                        GestureDetector(
                          onTap: () async {
                            await AuthService.logout();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const LogoutAnimationScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= Stats Section =================
              Column(
                children: [
                  _buildStatCard(
                    Icons.videocam,
                    '${profile['no_practise_test'] ?? 0}',
                    'Videos Watched',
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    Icons.emoji_events,
                    '${profile['total_practise_test_score'] ?? 0}',
                    'Learning Points',
                    Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    Icons.check_circle,
                    '${profile['no_practise_test'] ?? 0}',
                    'Practice Tests Completed',
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= Showcase Section =================
              const Text(
                'My Showcase',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              Container(
                height: 3,
                width: 60,
                margin: const EdgeInsets.only(top: 4, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Showcase Grid (2 per row)
              interests.isEmpty
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No interests selected yet.\nUpdate your profile to add interests!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: interests.length,
                    itemBuilder: (context, index) {
                      return ShowcaseCard(
                        title: interests[index],
                        icon: _getIconForInterest(interests[index]),
                        color: _getColorForInterest(index),
                      );
                    },
                  ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 0),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            radius: 20,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
