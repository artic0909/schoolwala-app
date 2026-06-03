import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'profile_edit_screen.dart';
import 'splash_screen.dart';
import '../services/auth_service.dart';
import '../widgets/global_bottom_bar.dart';
import '../widgets/app_drawer.dart';

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
        final decodedString = interestIn.replaceAll('\\"', '"');
        if (decodedString.startsWith('[')) {
          final List<dynamic> parsed = jsonDecode(decodedString);
          return List<String>.from(parsed);
        }
        return [decodedString];
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
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
        drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
        bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
        bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),
      );
    }

    final student = _profileData!['student'];
    final profile = _profileData!['profile'];
    final interests = _getInterests();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= Header & Avatar Section =================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Cover Photo
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E2A4F), // Dark Navy variant
                        Color(0xFF2C3E75),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle decorative patterns
                      Positioned(
                        top: -50,
                        right: -50,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -20,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Avatar
                Positioned(
                  top: 170, // Overlapping the cover photo
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: AuthService.userNotifier,
                        builder: (context, userData, _) {
                          final userProfile = userData?['profile'] ?? userData;
                          final profileImage = (userProfile is Map) ? userProfile['profile_image'] : null;
                          final profileImageUrl = profileImage != null
                              ? 'https://schoolwala.info/storage/$profileImage'
                              : null;

                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryOrange,
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
                    ),
                  ),
                ),
                
                // Floating Badges
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: 180 - _animation.value,
                      right: MediaQuery.of(context).size.width / 2 - 90,
                      child: _buildBadge(Icons.star, Colors.pinkAccent),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: 250 + _animation.value,
                      left: MediaQuery.of(context).size.width / 2 - 100,
                      child: _buildBadge(Icons.lightbulb, Colors.amber),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 80), // Space for avatar

            // ================= User Info & Actions =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${student['student_id'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Curious learner exploring the world!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileEditScreen(profileData: _profileData!),
                            ),
                          );
                          if (result == true) {
                            _loadProfile();
                          }
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          'Update Profile',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () async {
                          await AuthService.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 36),

            // ================= Statistics Section =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.videocam_rounded,
                    value: '${profile['no_practise_test'] ?? 0}',
                    label: 'Videos',
                    color: const Color(0xFF3B9EFF),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.emoji_events_rounded,
                    value: '${profile['total_practise_test_score'] ?? 0}',
                    label: 'Points',
                    color: const Color(0xFFFF9F43),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.check_circle_rounded,
                    value: '${profile['no_practise_test'] ?? 0}',
                    label: 'Tests',
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ================= Showcase Section =================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'My Showcase',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  interests.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(Icons.interests_outlined, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No interests selected yet.\nUpdate your profile to add interests!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: interests.length,
                          itemBuilder: (context, index) {
                            return _buildShowcaseCard(
                              interests[index],
                              _getIconForInterest(interests[index]),
                              _getColorForInterest(index),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(studentName: widget.studentName, currentRoute: 'Profile'),
      bottomNavigationBar: const GlobalBottomBar(currentIndex: 3),
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
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 100,
              color: color.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
