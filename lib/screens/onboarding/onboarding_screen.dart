import 'package:flutter/material.dart';
import 'package:simogura/screens/auth/login_screen.dart';

// ── Uncomment saat login screen sudah siap ──
// import '../auth/login_screen.dart';

// ─────────────────────────────────────────────────────────────
//  WARNA
// ─────────────────────────────────────────────────────────────
class _C {
  static const navy = Color(0xFF0C344D);
  static const blue = Color(0xFF2FA8D5);
  static const white = Color(0xFFFFFFFF);
  static const dotOff = Color(0xFF3A6A8A);
}

// ─────────────────────────────────────────────────────────────
//  DATA TIAP HALAMAN
// ─────────────────────────────────────────────────────────────
class _PageData {
  final String imagePath;
  final String title;
  final String description;

  const _PageData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

const _pages = [
  _PageData(
    imagePath: 'assets/images/on_boarding1.png',
    title: 'Monitoring IoT',
    description:
        'Pantau kondisi kolam secara real-time! Dengan teknologi IoT, Anda dapat memantau '
        'suhu, kelembapan, dan kualitas air langsung dari smartphone tanpa harus ke lokasi.',
  ),
  _PageData(
    imagePath: 'assets/images/on_boarding2.png',
    title: 'Manajemen Siklus',
    description:
        'Atur dan pantau setiap siklus pemeliharaan ikan dengan mudah. Anda dapat mengelola aktivitas'
        'harian kolam dengan lebih efisien dan memastikan produktivitas tetap optimal.',
  ),
  _PageData(
    imagePath: 'assets/images/on_boarding3.png',
    title: 'Data Real-Time',
    description:
        'Dapatkan data terbaru setiap saat untuk pengambilan keputusan cepat dan akurat. '
        'Visualisasi data membantu Anda memahami performa kolam secara menyeluruh.',
  ),
];

// ─────────────────────────────────────────────────────────────
//  ONBOARDING SCREEN
// ─────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── AREA ATAS: putih + gambar ─────────────────
            Expanded(
              child: Container(
                color: _C.white,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Image.asset(
                      _pages[i].imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // ── CARD BAWAH: ada margin kiri-kanan ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                20,
              ), // ✅ margin kiri-kanan
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  color: _C.navy,
                  borderRadius: BorderRadius.circular(
                    28,
                  ), // ✅ semua sudut rounded
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _C.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _current ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _current ? _C.blue : _C.dotOff,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Judul
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Text(
                        _pages[_current].title,
                        key: ValueKey(_current),
                        style: const TextStyle(
                          color: _C.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Deskripsi
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Text(
                        _pages[_current].description,
                        key: ValueKey('desc_$_current'),
                        style: TextStyle(
                          color: _C.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _goToLogin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.white,
                          foregroundColor: _C.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
