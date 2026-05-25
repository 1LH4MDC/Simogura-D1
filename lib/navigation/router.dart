import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/admin/home/admin_home_screen.dart';
import '../screens/user/home/user_home_screen.dart';

// ─────────────────────────────────────────────────────────────
//  APP ROUTER
//  Cek session → arahkan ke halaman yang tepat
//
//  Alur:
//  Admin : AppRouter → AdminHomeScreen → pilih kolam
//                    → AdminBottomNav(user, kolam)
//
//  User  : AppRouter → UserHomeScreen  → pilih kolam
//                    → UserBottomNav(user, kolam)
// ─────────────────────────────────────────────────────────────
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  Future<UserModel?> _getSavedUser() async {
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return null;
    return await AuthRepository().fetchProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _getSavedUser(),
      builder: (context, snapshot) {

        // ── Loading ────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C344D),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final user = snapshot.data;

        // ── Belum login → onboarding ───────────────────
        if (user == null) {
          return const OnboardingScreen();
        }

        // ── Admin → AdminHomeScreen (pilih kolam dulu) ─
        if (user.isAdmin) {
          return AdminHomeScreen(user: user);
        }

        // ── User → UserHomeScreen (pilih kolam dulu) ───
        return UserHomeScreen(user: user);
      },
    );
  }
}