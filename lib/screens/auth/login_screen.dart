import 'package:flutter/material.dart';
import 'package:simogura/screens/admin/home/admin_home_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../navigation/admin_bottom_nav.dart';
import '../../navigation/user_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
//  WARNA
// ─────────────────────────────────────────────────────────────
class _C {
  static const navy  = Color(0xFF0C344D);
  static const white = Color(0xFFFFFFFF);
  static const grey  = Color(0xFF9E9E9E);
  static const line  = Color(0xFFE0E0E0);
  static const text  = Color(0xFF333333);
  static const hint  = Color(0xFFAAAAAA);
}

// ─────────────────────────────────────────────────────────────
//  LOGIN SCREEN
// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl    = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _authController  = AuthController(); // ✅ renamed dari AkunController

  bool _rememberMe  = true;
  bool _obscurePass = true;
  bool _isLoading   = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username dan password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Panggil AuthController (bukan AkunController)
      final user = await _authController.login(username, password);

      if (!mounted) return;

      // ✅ Navigasi berdasarkan role — hapus semua route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => user.isAdmin
              ? AdminHomeScreen(user: user)   // → Admin
              : UserBottomNav(user: user),   // → Petugas
        ),
        (route) => false, // hapus semua history (onboarding, login)
      );
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();
      // Bersihkan prefix 'Exception:' jika ada
      if (errorMsg.startsWith('Exception:')) {
        errorMsg = errorMsg.replaceFirst('Exception:', '').trim();
      }

      _showSnackBar(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2E44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.navy,
      body: SafeArea(
        child: Column(
          children: [
            // ── AREA ATAS: Logo ────────────────────────────
            Expanded(
              flex: 38,
              child: Center(
                child: Image.asset(
                  'assets/images/logo_dan_nama.png',
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ── CARD PUTIH: Form Login ─────────────────────
            Expanded(
              flex: 62,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                decoration: BoxDecoration(
                  color: _C.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildUnderlineField(
                        controller: _usernameCtrl,
                        hint: 'Username',
                        suffixIcon: const Icon(
                          Icons.person_outline,
                          color: _C.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildUnderlineField(
                        controller: _passwordCtrl,
                        hint: 'Password',
                        obscure: _obscurePass,
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          child: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _C.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRememberMe(),
                      const SizedBox(height: 28),
                      _buildLoginButton(),
                      const SizedBox(height: 24),
                      _buildFooterText(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: tombol back + judul ────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _C.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left, color: _C.text, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Selamat Datang\ndi Simogura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Pantau kondisi kolam Anda secara real-time',
                textAlign: TextAlign.center,
                style: TextStyle(color: _C.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48), // spacer agar judul tetap center
      ],
    );
  }

  // ── Remember me ────────────────────────────────────
  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: _C.navy,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: _C.navy),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Remember me',
          style: TextStyle(color: _C.text, fontSize: 13),
        ),
      ],
    );
  }

  // ── Tombol Login ───────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.navy,
          foregroundColor: _C.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  // ── Footer: teks kebijakan ─────────────────────────
  Widget _buildFooterText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(color: _C.grey, fontSize: 11, height: 1.5),
          children: [
            TextSpan(text: 'Dengan masuk, Anda menyetujui '),
            TextSpan(
              text: 'Kebijakan Privasi & Syarat Penggunaan',
              style: TextStyle(
                color: _C.navy,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: _C.navy,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  // ── TextField underline ────────────────────────────
  Widget _buildUnderlineField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _C.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.hint, fontSize: 14),
        suffixIcon: suffixIcon,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _C.line, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _C.navy, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: false,
      ),
    );
  }
}