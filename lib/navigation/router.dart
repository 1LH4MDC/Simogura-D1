import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../navigation/admin_bottom_nav.dart';
import '../navigation/user_bottom_nav.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  // Cek apakah user sudah pernah login (ada data tersimpan)
  Future<UserModel?> _getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return null;

    // Ambil data user dari Supabase berdasarkan id yang tersimpan
    return await AuthRepository().fetchProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _getSavedUser(),
      builder: (context, snapshot) {

        // ── Loading ──────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C344D),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final user = snapshot.data;

        // ── Belum login → onboarding ─────────────────
        if (user == null) {
          return const OnboardingScreen();
        }

        // ── Admin → admin nav ─────────────────────────
        if (user.isAdmin) {
          return AdminBottomNav(user: user);
        }

        // ── User/Petugas → user nav ───────────────────
        return UserBottomNav(user: user);
      },
    );
  }
}