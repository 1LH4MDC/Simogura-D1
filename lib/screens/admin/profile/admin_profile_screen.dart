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
  static const hint    = Color(0xFFAAAAAA);
  static const green   = Color(0xFF4CAF50);
  static const danger  = Color(0xFFE53935);
  static const logout  = Color(0xFFB92025);
}

// ─────────────────────────────────────────────────────────────
//  ADMIN PROFILE SCREEN
// ─────────────────────────────────────────────────────────────
class AdminProfileScreen extends StatefulWidget {
  final UserModel user;
  const AdminProfileScreen({super.key, required this.user});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _authRepo = AuthRepository();

  // ── Mode tampilan ──────────────────────────────────
  bool _isEditingProfil   = false;
  bool _isEditingPassword = false;
  bool _isSaving          = false;

  // ── Controllers profil ─────────────────────────────
  late final TextEditingController _usernameCtrl;

  // ── Controllers password ───────────────────────────
  final _passLamaCtrl    = TextEditingController();
  final _passBaruCtrl    = TextEditingController();
  final _passKonfirmCtrl = TextEditingController();

  bool _obscureLama    = true;
  bool _obscureBaru    = true;
  bool _obscureKonfirm = true;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passLamaCtrl.dispose();
    _passBaruCtrl.dispose();
    _passKonfirmCtrl.dispose();
    super.dispose();
  }

  // ── Inisial avatar dari username ───────────────────
  String get _avatar {
    final name = widget.user.username ?? '';
    if (name.isEmpty) return 'A';
    return name[0].toUpperCase();
  }

  // ═══════════════════════════════════════════════════
  //  SIMPAN PROFIL
  // ═══════════════════════════════════════════════════
  Future<void> _simpanProfil() async {
    final username = _usernameCtrl.text.trim();

    if (username.isEmpty) {
      _showSnack('Username tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _authRepo.updateProfile(
        widget.user.id,
        {'username': username},
      );
      setState(() => _isEditingProfil = false);
      _showSnack('Profil berhasil diperbarui');
    } catch (e) {
      _showSnack('Gagal memperbarui profil: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ═══════════════════════════════════════════════════
  //  SIMPAN PASSWORD
  // ═══════════════════════════════════════════════════
  Future<void> _simpanPassword() async {
    final lama    = _passLamaCtrl.text;
    final baru    = _passBaruCtrl.text;
    final konfirm = _passKonfirmCtrl.text;

    if (lama.isEmpty || baru.isEmpty || konfirm.isEmpty) {
      _showSnack('Semua field password wajib diisi', isError: true);
      return;
    }
    if (baru.length < 6) {
      _showSnack('Password baru minimal 6 karakter', isError: true);
      return;
    }
    if (baru != konfirm) {
      _showSnack('Konfirmasi password tidak sesuai', isError: true);
      return;
    }
    if (lama == baru) {
      _showSnack('Password baru tidak boleh sama dengan password lama',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Verifikasi password lama dulu
      await _authRepo.login(widget.user.username ?? '', lama);

      // Kalau berhasil → update password baru
      await _authRepo.updateProfile(
        widget.user.id,
        {'password': baru},
      );

      setState(() {
        _isEditingPassword = false;
        _passLamaCtrl.clear();
        _passBaruCtrl.clear();
        _passKonfirmCtrl.clear();
      });
      _showSnack('Password berhasil diubah');
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Password salah')) {
        msg = 'Password lama tidak sesuai';
      }
      _showSnack(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                Navigator.pop(context);
                await _authRepo.logout();
                if (!mounted) return;
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
        // Tombol batal saat mode edit
        actions: [
          if (_isEditingProfil || _isEditingPassword)
            TextButton(
              onPressed: () => setState(() {
                _isEditingProfil   = false;
                _isEditingPassword = false;
                _usernameCtrl.text = widget.user.username ?? '';
                _passLamaCtrl.clear();
                _passBaruCtrl.clear();
                _passKonfirmCtrl.clear();
              }),
              child: const Text(
                'Batal',
                style: TextStyle(color: _C.white, fontSize: 13),
              ),
            ),
        ],
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

            // ── Card Ubah Password ────────────────────
            _buildPasswordCard(),
            const SizedBox(height: 14),

            // ── Tombol Edit Profil / Simpan ───────────
            if (!_isEditingPassword)
              _buildPrimaryButton(
                label:   _isEditingProfil ? 'Simpan Perubahan' : 'Edit Profil',
                icon:    _isEditingProfil
                    ? Icons.save_outlined
                    : Icons.edit_outlined,
                color:   _isEditingProfil ? _C.green : _C.navy,
                onTap:   _isEditingProfil ? _simpanProfil : () {
                  setState(() => _isEditingProfil = true);
                },
              ),

            // ── Tombol Simpan Password ────────────────
            if (_isEditingPassword) ...[
              _buildPrimaryButton(
                label:  'Simpan Password',
                icon:   Icons.save_outlined,
                color:  _C.green,
                onTap:  _simpanPassword,
              ),
            ],

            const SizedBox(height: 10),

            // ── Tombol Logout ─────────────────────────
            if (!_isEditingProfil && !_isEditingPassword)
              _buildPrimaryButton(
                label:  'Keluar',
                icon:   Icons.logout,
                color:  _C.logout,
                onTap:  _showLogoutDialog,
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
          child: Text(
            widget.user.isAdmin ? 'Admin (Pengelola BUMDes)' : 'Petugas Lapangan',
            style: const TextStyle(
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

          if (!_isEditingProfil) ...[
            // Mode lihat
            _infoRow(Icons.person_outline,          'Username', widget.user.username ?? '-'),
            _divider(),
            _infoRow(Icons.manage_accounts_outlined, 'Role',
                widget.user.isAdmin ? 'Admin (Pengelola BUMDes)' : 'Petugas Lapangan'),
            _divider(),
            _infoRow(Icons.access_time_outlined,     'Login Terakhir',
                widget.user.lastLoginAt != null
                    ? _formatDate(widget.user.lastLoginAt!)
                    : '-'),
          ] else ...[
            // Mode edit
            _fieldLabel('Username'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _usernameCtrl,
              hint:       'Masukkan username baru',
              icon:       Icons.person_outline,
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD UBAH PASSWORD
  // ─────────────────────────────────────────────────
  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Keamanan'),
              if (!_isEditingProfil && !_isEditingPassword)
                GestureDetector(
                  onTap: () => setState(() => _isEditingPassword = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _C.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ubah',
                      style: TextStyle(
                        color: _C.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_isEditingPassword) ...[
            // Mode lihat — tampilkan bintang
            _infoRow(Icons.lock_outline, 'Password', '••••••••'),
          ] else ...[
            // Mode edit password
            _fieldLabel('Password Lama'),
            const SizedBox(height: 6),
            _buildTextField(
              controller:  _passLamaCtrl,
              hint:        'Masukkan password lama',
              icon:        Icons.lock_outline,
              obscure:     _obscureLama,
              suffixIcon:  _eyeIcon(
                visible: _obscureLama,
                onTap:   () => setState(() => _obscureLama = !_obscureLama),
              ),
            ),
            const SizedBox(height: 14),

            _fieldLabel('Password Baru'),
            const SizedBox(height: 6),
            _buildTextField(
              controller:  _passBaruCtrl,
              hint:        'Minimal 6 karakter',
              icon:        Icons.lock_outline,
              obscure:     _obscureBaru,
              suffixIcon:  _eyeIcon(
                visible: _obscureBaru,
                onTap:   () => setState(() => _obscureBaru = !_obscureBaru),
              ),
            ),
            const SizedBox(height: 14),

            _fieldLabel('Konfirmasi Password Baru'),
            const SizedBox(height: 6),
            _buildTextField(
              controller:  _passKonfirmCtrl,
              hint:        'Ulangi password baru',
              icon:        Icons.lock_outline,
              obscure:     _obscureKonfirm,
              suffixIcon:  _eyeIcon(
                visible: _obscureKonfirm,
                onTap:   () => setState(
                  () => _obscureKonfirm = !_obscureKonfirm,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  TOMBOL UTAMA (Edit / Simpan / Logout)
  // ─────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String       label,
    required IconData     icon,
    required Color        color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: _C.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
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

  Widget _divider() => Divider(
        color: _C.line,
        height: 1,
        thickness: 1,
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: _C.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String  hint,
    required IconData icon,
    bool     obscure    = false,
    Widget?  suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller:    controller,
      obscureText:   obscure,
      keyboardType:  keyboardType,
      style: const TextStyle(color: _C.text, fontSize: 14),
      decoration: InputDecoration(
        hintText:    hint,
        hintStyle:   const TextStyle(color: _C.hint, fontSize: 13),
        prefixIcon:  Icon(icon, color: _C.subtext, size: 18),
        suffixIcon:  suffixIcon,
        filled:      true,
        fillColor:   _C.bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.navy, width: 1.5),
        ),
      ),
    );
  }

  Widget _eyeIcon({required bool visible, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Icon(
          visible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: _C.subtext,
          size: 18,
        ),
      );

  // ─────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _C.danger : _C.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h.$min WIB';
  }
}