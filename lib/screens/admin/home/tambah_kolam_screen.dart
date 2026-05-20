import 'package:flutter/material.dart';
import '../../../controllers/kolam_controller.dart';
import '../../../data/models/user_model.dart';

// ─────────────────────────────────────────────────────────────
//  WARNA
// ─────────────────────────────────────────────────────────────
class _C {
  static const navy    = Color(0xFF0C344D);
  static const white   = Color(0xFFFFFFFF);
  static const bg      = Color(0xFFF4F6F8);
  static const text    = Color(0xFF1A2E44);
  static const subtext = Color(0xFF7A9BB0);
  static const hint    = Color(0xFFAAAAAA);
  static const line    = Color(0xFFE0E8EF);
}

// ─────────────────────────────────────────────────────────────
//  TAMBAH KOLAM SCREEN
// ─────────────────────────────────────────────────────────────
class TambahKolamScreen extends StatefulWidget {
  final UserModel user;
  const TambahKolamScreen({super.key, required this.user});

  @override
  State<TambahKolamScreen> createState() => _TambahKolamScreenState();
}

class _TambahKolamScreenState extends State<TambahKolamScreen> {
  final _kolamController = KolamController();

  // ── Controllers ───────────────────────────────────
  final _namaCtrl      = TextEditingController();
  final _alamatCtrl    = TextEditingController();
  final _totalIkanCtrl = TextEditingController();
  final _targetBobotCtrl  = TextEditingController();
  final _durasiTargetCtrl = TextEditingController();

  DateTime? _tanggalMulai;
  bool _isSaving = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _totalIkanCtrl.dispose();
    _targetBobotCtrl.dispose();
    _durasiTargetCtrl.dispose();
    super.dispose();
  }

  // ── Pilih tanggal ─────────────────────────────────
  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _C.navy),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _tanggalMulai = picked);
  }

  // ── Validasi & Simpan ─────────────────────────────
  void _simpanKolam() async {
    final nama    = _namaCtrl.text.trim();
    final alamat  = _alamatCtrl.text.trim();
    final totalIkanStr   = _totalIkanCtrl.text.trim();
    final targetBobotStr = _targetBobotCtrl.text.trim();
    final durasiStr      = _durasiTargetCtrl.text.trim();

    // validasi kosong
    if (nama.isEmpty || alamat.isEmpty || totalIkanStr.isEmpty ||
        targetBobotStr.isEmpty || durasiStr.isEmpty || _tanggalMulai == null) {
      _showSnack('Semua field wajib diisi');
      return;
    }

    // validasi angka
    final totalIkan   = int.tryParse(totalIkanStr);
    final targetBobot = double.tryParse(targetBobotStr);
    final durasi      = int.tryParse(durasiStr);

    if (totalIkan == null || totalIkan <= 0) {
      _showSnack('Total ikan harus berupa angka lebih dari 0');
      return;
    }
    if (targetBobot == null || targetBobot <= 0) {
      _showSnack('Target bobot harus berupa angka lebih dari 0');
      return;
    }
    if (durasi == null || durasi <= 0) {
      _showSnack('Durasi target harus berupa angka lebih dari 0');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _kolamController.createKolam(
        nama:         nama,
        alamat:       alamat,
        totalIkan:    totalIkan,
        tanggalMulai: _tanggalMulai!,
        targetBobot:  targetBobot,
        durasiTarget: durasi,
        userId:       widget.user.id,
      );

      if (!mounted) return;
      Navigator.pop(context, true); // ✅ kirim true → home refresh
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal menyimpan kolam: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2E44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, color: _C.text, size: 28),
        ),
        title: const Text(
          'Tambah Kolam',
          style: TextStyle(
            color: _C.text,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Form ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Kolam',
                        style: TextStyle(
                          color: _C.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Kolam
                      _buildLabel('Nama Kolam'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _namaCtrl,
                        hint: 'Tuliskan nama kolam',
                      ),
                      const SizedBox(height: 16),

                      // Alamat Kolam
                      _buildLabel('Alamat Kolam'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _alamatCtrl,
                        hint: 'Tulis alamat',
                      ),
                      const SizedBox(height: 16),

                      // Total Ikan
                      _buildLabel('Total Ikan (ekor)'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _totalIkanCtrl,
                        hint: 'Contoh: 1000',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Mulai Kolam
                      _buildLabel('Tanggal Mulai Kolam'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pilihTanggal,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: _C.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: _tanggalMulai != null
                                ? Border.all(
                                    color: _C.navy.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: _C.subtext, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _tanggalMulai != null
                                    ? '${_tanggalMulai!.day.toString().padLeft(2, '0')}/'
                                        '${_tanggalMulai!.month.toString().padLeft(2, '0')}/'
                                        '${_tanggalMulai!.year}'
                                    : 'Pilih tanggal',
                                style: TextStyle(
                                  color: _tanggalMulai != null
                                      ? _C.text
                                      : _C.hint,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Bobot
                      _buildLabel('Target Bobot Ikan (kg)'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _targetBobotCtrl,
                        hint: 'Contoh: 1.5',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),

                      // Durasi Target
                      _buildLabel('Durasi Target (Hari)'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _durasiTargetCtrl,
                        hint: 'Contoh: 35',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tombol Simpan ─────────────────────────
            Container(
              color: _C.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanKolam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.navy,
                    foregroundColor: _C.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Kolam',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          text,
          style: const TextStyle(
              color: _C.text, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _C.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.hint, fontSize: 13),
        filled: true,
        fillColor: _C.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.navy, width: 1.5),
        ),
      ),
    );
  }
}