import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../screens/user/home/user_home_screen.dart';
import '../screens/user/monitoring/user_monitoring_screen.dart';
import '../screens/user/profile/user_profile_screen.dart';
import '../data/models/user_model.dart';
import '../data/models/kolam_model.dart';

// ─────────────────────────────────────────────────────────────
//  USER BOTTOM NAV
//  Muncul SETELAH kolam dipilih dari UserHomeScreen.
//  UserHomeScreen sendiri TIDAK menggunakan widget ini.
// ─────────────────────────────────────────────────────────────
class UserBottomNav extends StatefulWidget {
  final UserModel  user;
  final KolamModel kolam; // ← kolam yang dipilih dari UserHomeScreen

  const UserBottomNav({
    super.key,
    required this.user,
    required this.kolam,
  });

  @override
  State<UserBottomNav> createState() => _UserBottomNavState();
}

class _UserBottomNavState extends State<UserBottomNav> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Tab 0 – Dashboard kolam yang dipilih (readonly)
      UserHomeScreen(
        user:  widget.user,
        kolam: widget.kolam,
      ),

      // Tab 1 – Monitoring sensor kolam yang dipilih
      UserMonitoringScreen(
        user:  widget.user,
        kolam: widget.kolam,
      ),

      // Tab 2 – Profil user (lihat saja)
      UserProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon:       Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label:      AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label:      AppStrings.navMonitoring,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label:      AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}