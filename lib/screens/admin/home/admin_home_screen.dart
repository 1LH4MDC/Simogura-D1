import 'package:flutter/material.dart';
import '../../../controllers/kolam_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/kolam_model.dart';
import 'tambah_kolam_screen.dart';
import 'admin_dashboard_screen.dart';

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
}

// ─────────────────────────────────────────────────────────────
//  ADMIN HOME SCREEN — Empty state atau list kolam
// ─────────────────────────────────────────────────────────────
class AdminHomeScreen extends StatefulWidget {
  final UserModel user; // ✅ UserModel, bukan AkunModel
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _kolamController = KolamController();
  List<KolamModel> _kolams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKolams();
  }

  Future<void> _fetchKolams() async {
    setState(() => _isLoading = true);
    try {
      final data = await _kolamController.getKolams(widget.user.id);
      setState(() => _kolams = data);
    } catch (e) {
      debugPrint('FETCH_KOLAM_ERROR: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Buka tambah kolam → refresh jika berhasil ─────
  Future<void> _goToTambahKolam() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahKolamScreen(user: widget.user),
      ),
    );
    if (result == true) _fetchKolams();
  }

  // ── Buka dashboard kolam yang dipilih ─────────────
  void _bukaKolam(KolamModel kolam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(
          user:  widget.user,
          kolam: kolam,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──────────────────────────────
              _buildGreeting(),
              const SizedBox(height: 24),

              // ── Content ───────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _kolams.isEmpty
                        ? _buildEmptyState()
                        : _buildKolamList(),
              ),
            ],
          ),
        ),
      ),

      // ── FAB muncul hanya jika sudah ada kolam ────────
      floatingActionButton: (!_isLoading && _kolams.isNotEmpty)
          ? FloatingActionButton(
              onPressed: _goToTambahKolam,
              backgroundColor: _C.navy,
              child: const Icon(Icons.add, color: _C.white),
            )
          : null,
    );
  }

  // ── Greeting + notifikasi ─────────────────────────
  Widget _buildGreeting() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _C.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: _C.navy, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hallo, ${widget.user.username}', // ✅ username dari UserModel
                style: const TextStyle(
                  color: _C.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Pantau kolam anda',
                style: TextStyle(color: _C.subtext, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: _C.navy),
        ),
      ],
    );
  }

  // ── Empty state ───────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ganti dengan Image.asset('assets/images/kolam.png') jika ada
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.waves, size: 60, color: _C.subtext),
          ),
          const SizedBox(height: 28),
          const Text(
            'Belum memiliki kolam',
            style: TextStyle(
              color: _C.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan kolam Anda untuk dikelola\ndi aplikasi Simogura',
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.subtext, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _goToTambahKolam,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.navy,
                foregroundColor: _C.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Tambah Kolam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── List kolam ────────────────────────────────────
  Widget _buildKolamList() {
    return ListView.builder(
      itemCount: _kolams.length,
      itemBuilder: (context, index) {
        final kolam = _kolams[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _C.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.waves, color: _C.navy),
            ),
            title: Text(
              kolam.nama, // ✅ .nama bukan .lokasi
              style: const TextStyle(
                color: _C.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              // ✅ info dari KolamModel baru (tidak ada siklus di sini)
              '${kolam.totalIkan} ekor · Target ${kolam.durasiTarget} hari',
              style: const TextStyle(color: _C.subtext, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // badge aktif/selesai
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kolam.isAktif
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kolam.isAktif ? 'Aktif' : 'Selesai',
                    style: TextStyle(
                      color: kolam.isAktif ? Colors.green : _C.subtext,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: _C.subtext),
              ],
            ),
            onTap: () => _bukaKolam(kolam), // ✅ buka AdminDashboardScreen
          ),
        );
      },
    );
  }
}