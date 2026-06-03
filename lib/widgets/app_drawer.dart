import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/student_service.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/mychapters_screen.dart';
import '../screens/myclass_screen.dart';
import '../screens/login_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/fees_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/support_screen.dart';

class AppDrawer extends StatefulWidget {
  final String studentName;

  final String currentRoute;
  const AppDrawer({super.key, required this.studentName, this.currentRoute = 'Home'});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<SubjectData> _subjects = [];
  bool _isLoadingSubjects = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final result = await StudentService.getMyClass();
    if (mounted) {
      if (result['success']) {
        try {
          final data = result['data'];
          List<dynamic> list = [];
          
          if (data is Map) {
            if (data.containsKey('subjects')) {
              list = data['subjects'] ?? [];
            } else if (data.containsKey('data') &&
                data['data'] is Map &&
                data['data'].containsKey('subjects')) {
              list = data['data']['subjects'] ?? [];
            } else if (data.containsKey('data') && data['data'] is List) {
              list = data['data'];
            }
          } else if (data is List) {
            list = data;
          }

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

          setState(() {
            _subjects = list.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              int assetIndex = index % fallbackIcons.length;
              int imgIndex = index % fallbackImages.length;
              
              String? bgImage = item['background_image'];
              String? backgroundImageUrl;
              if (bgImage != null && bgImage.toString().isNotEmpty) {
                backgroundImageUrl = 'https://schoolwala.info/storage/$bgImage';
              }

              return SubjectData(
                id: item['id']?.toString() ?? '',
                name: item['name'] ?? '',
                englishName: item['name'] ?? '',
                description: 'Build strong foundation in concepts with interactive problems and visual learning.',
                icon: fallbackIcons[assetIndex],
                imagePath: fallbackImages[imgIndex],
                colors: fallbackColors[imgIndex],
                backgroundImageUrl: backgroundImageUrl,
              );
            }).toList();
            _isLoadingSubjects = false;
          });
        } catch (e) {
          setState(() => _isLoadingSubjects = false);
        }
      } else {
        setState(() => _isLoadingSubjects = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  isSelected: widget.currentRoute == 'Home',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (widget.currentRoute != 'Home') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyClassScreen(studentName: widget.studentName)),
                        (route) => false,
                      );
                    }
                  },
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.class_rounded, color: AppColors.primaryOrange),
                    ),
                    title: const Text(
                      'My Classes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 20, bottom: 8),
                    children: _isLoadingSubjects
                        ? [const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())]
                        : _subjects.map((subject) {
                            return ListTile(
                              leading: Icon(subject.icon, color: AppColors.textGray, size: 20),
                              title: Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyChaptersScreen(
                                      subject: subject,
                                      studentName: widget.studentName,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'My Profile',
                  isSelected: widget.currentRoute == 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != 'Profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(studentName: widget.studentName),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Transactions',
                  isSelected: widget.currentRoute == 'Transactions',
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != 'Transactions') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionsScreen(studentName: widget.studentName),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payment_rounded,
                  title: 'Fees',
                  isSelected: widget.currentRoute == 'Fees',
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != 'Fees') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeesScreen(studentName: widget.studentName),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  isSelected: widget.currentRoute == 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != 'Privacy Policy') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(studentName: widget.studentName),
                        ),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  isSelected: widget.currentRoute == 'Support',
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != 'Support') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupportScreen(studentName: widget.studentName),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 16, color: Colors.transparent),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  textColor: Colors.red,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Schoolwala App',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.primaryOrange.withValues(alpha: 0.1) : Colors.transparent,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange : AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? (isSelected ? Colors.white : AppColors.primaryOrange)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: textColor ?? (isSelected ? AppColors.primaryOrange : AppColors.darkNavy),
          ),
        ),
        onTap: onTap,
        hoverColor: AppColors.primaryOrange.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildHeader() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, userData, _) {
        final student = userData?['student'] ?? userData;
        final profile = userData?['profile'] ?? userData;
        
        final name = (student is Map)
            ? (student['student_name'] ?? widget.studentName)
            : widget.studentName;
            
        final studentId = (student is Map) 
            ? student['student_id']?.toString() ?? student['id']?.toString() ?? 'ID: N/A' 
            : 'ID: N/A';
            
        final profileImage = (profile is Map) ? profile['profile_image'] : null;
        final profileImageUrl = profileImage != null
            ? 'https://schoolwala.info/storage/$profileImage'
            : null;

        return DrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.orangeGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: $studentId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
