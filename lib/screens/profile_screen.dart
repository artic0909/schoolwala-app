import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';
import '../widgets/showcase_card.dart';
import 'profile_edit_screen.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // ================= Breadcrumb Navigation =================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '/',
                      style: TextStyle(color: AppColors.textGray),
                    ),
                    const SizedBox(width: 8),

                    // Update Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ProfileEditScreen(
                                  currentName: widget.studentName,
                                  currentEmail:
                                      'student@schoolwala.com', // Placeholder
                                ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryOrange),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_square,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Update Profile',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    const Text(
                      '/',
                      style: TextStyle(color: AppColors.textGray),
                    ),
                    const SizedBox(width: 8),

                    // Logout Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryOrange),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.power_settings_new,
                              color: AppColors.darkNavy,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Logout',
                              style: TextStyle(
                                color: AppColors.darkNavy,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                      Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEAAA93),
                              width: 3,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/profile.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Animated Badges
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 0 + _animation.value, // Float down
                                right: 15,
                                child: _buildBadge(
                                  Icons.star,
                                  Colors.pinkAccent,
                                ),
                              ),
                              Positioned(
                                bottom: 0 - _animation.value, // Float up
                                right: 20,
                                child: _buildBadge(
                                  Icons.emoji_events,
                                  Colors.green,
                                ),
                              ),
                              Positioned(
                                bottom:
                                    40 + (_animation.value / 2), // Float slower
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
                    Text(
                      widget.studentName,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AppColors.darkNavy,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Student ID: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '25-SW-CLASS8-02',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Curious learner exploring the world of numbers and science! Currently in Class 8.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                        height: 1.4,
                      ),
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
                    '6',
                    'Videos Watched',
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    Icons.emoji_events,
                    '44',
                    'Learning Points',
                    Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    Icons.check_circle,
                    '6',
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: const [
                  ShowcaseCard(
                    title: 'Mathematic',
                    icon: Icons.calculate,
                    color: Colors.teal,
                  ),
                  ShowcaseCard(
                    title: 'Science',
                    icon: Icons.science,
                    color: Colors.lightBlue,
                  ),
                  ShowcaseCard(
                    title: 'Coding',
                    icon: Icons.computer,
                    color: Colors.cyan,
                  ),
                  ShowcaseCard(
                    title: 'Hindi',
                    icon: Icons.translate,
                    color: Colors.indigoAccent,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
