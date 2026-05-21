import 'package:flutter/material.dart';
import '../../../controllers/kolam_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/kolam_model.dart';

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
  static const line    = Color(0xFFE8EEF3);
  static const danger  = Color(0xFFB92025);
  static const green   = Color(0xFF4CAF50);
}

// ─────────────────────────────────────────────────────────────
//  DETAIL KOLAM SCREEN
// ─────────────────────────────────────────────────────────────
class DetailKolamScreen extends StatefulWidget {
  final UserModel  user;
  final KolamModel kolam;

  const DetailKolamScreen({
    super.key,
    required this.user,
    required this.kolam,
  });

  @override
  State<DetailKolamScreen> createState() => _DetailKolamScreenState();
}

class _DetailKolamScreenState extends State<DetailKolamScreen> {
  final _kolamController      = KolamController();
  final _populasiAkhirCtrl    = TextEditingController();
  final _totalBobotCtrl       = TextEditingController();
  final _konsumsiPakanCtrl    = TextEditingController();

  bool _isSelesai = false; // kolam sudah diselesaikan

  @override
  void dispose() {
    _populasiAkhirCtrl.dispose();
    _totalBobotCtrl.dispose();
    _konsumsiPakanCtrl.dispose();
    super.dispose();
  }

  // ── Format tanggal ────────────────────────────────
  String _formatTanggal(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  // ── Dialog konfirmasi selesaikan kolam ───────────
  void _showKonfirmasiSelesai() {
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _C.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: _C.danger,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selesaikan Kolam?',
              style: TextStyle(
                color: _C.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Kolam akan ditandai selesai dan tidak bisa diubah kembali.',
              style: TextStyle(color: _C.subtext, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 100,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.text,
                side: const BorderSide(color: _C.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Batal'),
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _selesaikanKolam();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.danger,
                foregroundColor: _C.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Ya, Selesai'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Proses selesaikan kolam ───────────────────────
  void _selesaikanKolam() async {
    final populasiStr = _populasiAkhirCtrl.text.trim();
    final bobotStr    = _totalBobotCtrl.text.trim();
    final pakanStr    = _konsumsiPakanCtrl.text.trim();

    // validasi — semua field wajib diisi
    if (populasiStr.isEmpty || bobotStr.isEmpty || pakanStr.isEmpty) {
      _showSnack('Isi semua data terlebih dahulu sebelum menyelesaikan kolam');
      return;
    }

    final populasi = int.tryParse(populasiStr);
    final bobot    = double.tryParse(bobotStr);
    final pakan    = double.tryParse(pakanStr);

    if (populasi == null || populasi < 0) {
      _showSnack('Populasi akhir harus berupa angka valid');
      return;
    }
    if (bobot == null || bobot < 0) {
      _showSnack('Total bobot akhir harus berupa angka valid');
      return;
    }
    if (pakan == null || pakan < 0) {
      _showSnack('Total konsumsi pakan harus berupa angka valid');
      return;
    }

    try {
      // Tandai kolam selesai di Supabase
      await _kolamController.selesaikanKolam(widget.kolam.id);

      if (!mounted) return;

      setState(() => _isSelesai = true);

      // Kembali ke home dengan signal refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal menyelesaikan kolam: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2E44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kolam = widget.kolam;

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
        title: Text(
          kolam.nama,
          style: const TextStyle(
            color: _C.text,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Konten utama ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Card: Data Kolam (readonly) ────
                    _buildDataKolamCard(kolam),
                    const SizedBox(height: 16),

                    // ── Form: Data Penyelesaian ────────
                    if (!kolam.status)
                      _buildSelesaiInfo()
                    else
                      _buildFormPenyelesaian(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Tombol Selesaikan Kolam ───────────────
            if (kolam.status && !_isSelesai)
              Container(
                color: _C.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showKonfirmasiSelesai,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: _C.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesaikan Kolam',
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

  // ─────────────────────────────────────────────────
  //  CARD DATA KOLAM (readonly)
  // ─────────────────────────────────────────────────
  Widget _buildDataKolamCard(KolamModel kolam) {
    return Container(
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
          // Judul section
          _buildSectionTitle('Data Kolam'),
          const SizedBox(height: 4),
          Text(
            'Data kolam pada siklus ${kolam.nama}',
            style: const TextStyle(color: _C.subtext, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Tabel data kolam
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _C.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildDataRow(
                  'Tanggal Mulai :',
                  _formatTanggal(kolam.tanggalMulai),
                ),
                const SizedBox(height: 10),
                _buildDataRow(
                  'Populasi Awal :',
                  '${_formatAngka(kolam.totalIkan)} ekor',
                ),
                const SizedBox(height: 10),
                _buildDataRow(
                  'Target Bobot :',
                  '${kolam.targetBobot} kg',
                ),
                const SizedBox(height: 10),
                _buildDataRow(
                  'Durasi Target :',
                  '${kolam.durasiTarget} hari',
                ),
                const SizedBox(height: 10),
                _buildDataRow(
                  'Alamat :',
                  kolam.alamat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  FORM PENYELESAIAN (isi sebelum selesaikan)
  // ─────────────────────────────────────────────────
  Widget _buildFormPenyelesaian() {
    return Container(
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
          _buildSectionTitle('Data Penyelesaian'),
          const SizedBox(height: 4),
          const Text(
            'Isi data akhir siklus sebelum menyelesaikan kolam',
            style: TextStyle(color: _C.subtext, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Populasi Akhir
          _buildLabel('Populasi Akhir (ekor)'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _populasiAkhirCtrl,
            hint: 'Contoh : 1.000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Total Bobot Akhir
          _buildLabel('Total Bobot Akhir (kg)'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _totalBobotCtrl,
            hint: 'Contoh : 2.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),

          // Total Konsumsi Pakan
          _buildLabel('Total Konsumsi Pakan (Gram)'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _konsumsiPakanCtrl,
            hint: 'Contoh : 4400',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  INFO KOLAM SUDAH SELESAI
  // ─────────────────────────────────────────────────
  Widget _buildSelesaiInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: _C.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kolam Sudah Selesai',
                  style: TextStyle(
                    color: _C.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Siklus kolam ini telah selesai dan diarsipkan.',
                  style: TextStyle(
                    color: _C.subtext,
                    fontSize: 12,
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
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _C.subtext, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _C.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: _C.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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

  String _formatAngka(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}