import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/profile_screen.dart';
import '../screens/myclass_screen.dart';
import '../screens/fees_screen.dart';
import '../services/auth_service.dart';

class GlobalBottomBar extends StatelessWidget {
  final int currentIndex;

  const GlobalBottomBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex && index != 4) return;

    final studentName = AuthService.userNotifier.value?['student']?['student_name'] ?? 'Student';

    switch (index) {
      case 0: // Home
        if (currentIndex != 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyClassScreen(studentName: studentName)),
            (route) => false,
          );
        }
        break;
      case 1: // My Classes (Placeholder for now)
        if (currentIndex != 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyClassScreen(studentName: studentName)),
          );
        }
        break;
      case 2: // Fees
        if (currentIndex != 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FeesScreen(studentName: studentName)),
          );
        }
        break;
      case 3: // Profile
        if (currentIndex != 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(studentName: studentName)),
          );
        }
        break;
      case 4: // More
        Scaffold.of(context).openDrawer();
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex > 3 ? 0 : currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray.withValues(alpha: 0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: 'My Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Fees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
