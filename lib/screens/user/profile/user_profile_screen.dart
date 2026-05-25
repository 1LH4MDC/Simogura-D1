import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../onboarding/onboarding_screen.dart';

// ─────────────────────────────────────────────────────────────
//  WARNA
// ─────────────────────────────────────────────────────────────
class _C {
  static const navy    = Color(0xFF0C344D);
  static const blue    = Color(0xFF2FA8D5);
  static const white   = Color(0xFFFFFFFF);
  static const bg      = Color(0xFFF4F6F8);
  static const text    = Color(0xFF1A2E44);
  static const subtext = Color(0xFF7A9BB0);
  static const line    = Color(0xFFE8EEF3);
  static const logout  = Color(0xFFB92025);
}

// ─────────────────────────────────────────────────────────────
//  USER PROFILE SCREEN (Read-Only)
// ─────────────────────────────────────────────────────────────
class UserProfileScreen extends StatefulWidget {
  final UserModel user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _authRepo = AuthRepository();

  // ── Inisial avatar dari username ───────────────────
  String get _avatar {
    final name = widget.user.username ?? '';
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  // ═══════════════════════════════════════════════════
  //  LOGOUT
  // ═══════════════════════════════════════════════════
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _C.logout.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: _C.logout, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keluar dari Sistem?',
              style: TextStyle(
                color: _C.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Apakah Anda yakin ingin keluar dari sistem?',
              style: TextStyle(color: _C.subtext, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Tombol Tidak
          SizedBox(
            width: 110,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.text,
                side: const BorderSide(color: _C.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tidak'),
            ),
          ),
          // Tombol Ya
          SizedBox(
            width: 110,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                await _authRepo.logout();
                if (!mounted) return;
                // Kembali ke halaman onboarding / login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.logout,
                foregroundColor: _C.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Ya, Keluar'),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.navy,
        foregroundColor: _C.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Avatar ────────────────────────────────
            _buildAvatar(),
            const SizedBox(height: 28),

            // ── Card Informasi Akun ───────────────────
            _buildInfoCard(),
            const SizedBox(height: 14),

            // ── Card Keamanan (Read Only) ─────────────
            _buildPasswordCard(),
            const SizedBox(height: 24),

            // ── Tombol Logout ─────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.logout,
                  foregroundColor: _C.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  AVATAR
  // ─────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Column(
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: _C.navy,
            shape: BoxShape.circle,
            border: Border.all(color: _C.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _C.navy.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _avatar,
              style: const TextStyle(
                color: _C.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.user.username ?? '-',
          style: const TextStyle(
            color: _C.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _C.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Petugas Lapangan',
            style: TextStyle(
              color: _C.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD INFORMASI AKUN
  // ─────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Informasi Akun'),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, 'Username', widget.user.username ?? '-'),
          _divider(),
          _infoRow(Icons.manage_accounts_outlined, 'Role', 'Petugas Lapangan'),
          _divider(),
          _infoRow(
            Icons.access_time_outlined, 
            'Login Terakhir',
            widget.user.lastLoginAt != null ? _formatDate(widget.user.lastLoginAt!) : '-'
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD UBAH PASSWORD (Read Only)
  // ─────────────────────────────────────────────────
  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Keamanan'),
          const SizedBox(height: 16),
          _infoRow(Icons.lock_outline, 'Password', '••••••••'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: _C.subtext, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hubungi Admin/Pengelola BUMDes jika Anda perlu merubah kata sandi.',
                    style: TextStyle(color: _C.subtext, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  HELPER WIDGETS
  // ─────────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _sectionTitle(String title) => Row(
        children: [
          Container(
            width: 4, height: 16,
            decoration: BoxDecoration(
              color: _C.navy,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _C.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _C.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _C.navy, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _C.subtext, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: _C.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _divider() => const Divider(
        color: _C.line,
        height: 1,
        thickness: 1,
      );

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h.$min WIB';
  }
}