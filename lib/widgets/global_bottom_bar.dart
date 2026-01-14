import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../screens/profile_screen.dart';
import '../screens/myclass_screen.dart';
import '../services/auth_service.dart';

class GlobalBottomBar extends StatelessWidget {
  final int currentIndex;

  const GlobalBottomBar({super.key, required this.currentIndex});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
                  studentName:
                      AuthService
                          .userNotifier
                          .value?['student']?['student_name'] ??
                      'Student',
                ),
          ),
        );
        break;
      case 1: // About
        _launchURL('https://www.schoolwala.info/about-us');
        break;
      case 2: // My Class
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => MyClassScreen(
                  studentName:
                      AuthService
                          .userNotifier
                          .value?['student']?['student_name'] ??
                      'Student',
                ),
          ),
        );
        break;
      case 3: // Privacy
        _launchURL('https://www.schoolwala.info/privacy-policy');
        break;
      case 4: // Support
        _launchURL('https://www.schoolwala.info/contact');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'My Class',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.privacy_tip_outlined),
            activeIcon: Icon(Icons.privacy_tip),
            label: 'Privacy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
