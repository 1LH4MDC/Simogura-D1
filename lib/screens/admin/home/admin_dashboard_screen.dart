import 'package:flutter/material.dart';
import 'package:simogura/screens/admin/home/detail_kolam_screen.dart';
import 'package:simogura/screens/admin/notifikasi/admin_notifikasi_screen.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/kolam_model.dart';
import '../../../data/models/sensor_model.dart';

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
  static const card    = Color(0xFFFFFFFF);
  static const green   = Color(0xFF4CAF50);
  static const warning = Color(0xFFF4A623);
  static const danger  = Color(0xFFE53935);
  static const line    = Color(0xFFE8EEF3);
}

// ─────────────────────────────────────────────────────────────
//  ADMIN DASHBOARD SCREEN
// ─────────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  final UserModel  user;
  final KolamModel kolam;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.kolam,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  // ⚠️ DATA DUMMY — ganti dengan stream dari SensorRepository nanti
  final SensorModel _sensor = SensorModel(
    suhu:        29.0,
    ph:          7.2,
    amonia:      20.0,
    ketinggian:  85.0,
    status:      'normal',
    lastUpdated: DateTime.now(),
  );

  // ⚠️ DUMMY — nanti ambil dari SiklusRepository
  int get _hariKe     => 12;
  int get _targetHari => widget.kolam.durasiTarget;
  double get _progressSiklus => (_hariKe / _targetHari).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── App Bar ───────────────────────────────────
            SliverAppBar(
              backgroundColor: _C.navy,
              foregroundColor: _C.white,
              pinned: true,
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    widget.kolam.nama,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.kolam.alamat,
                    style: TextStyle(
                      color: _C.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: _C.white),
                      onPressed: () {
                        // ✅ Tambahkan navigasi ke sini
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminNotifikasiScreen(user: widget.user), 
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: _C.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Card siklus + detail ───────────────
                    _buildSiklusCard(),
                    const SizedBox(height: 16),

                    // ── Banner status ──────────────────────
                    _buildStatusBanner(),
                    const SizedBox(height: 16),

                    // ── Label section monitoring ───────────
                    _buildSectionLabel(
                      'Monitoring Real-Time',
                      subtitle: 'Diperbarui: ${_formatTime(_sensor.lastUpdated)}',
                    ),
                    const SizedBox(height: 12),

                    // ── Card Suhu (full width) ─────────────
                    _buildSensorCardFull(
                      label:      'Suhu Air',
                      value:      _sensor.suhu.toStringAsFixed(1),
                      unit:       '°C',
                      statusText: _getSuhuStatus(_sensor.suhu),
                      icon:       Icons.thermostat_outlined,
                      iconColor:  const Color(0xFF4FC3F7),
                      valueColor: _getStatusColor(_getSuhuStatus(_sensor.suhu)),
                      rangeLabel: 'Normal: 26°C – 30°C',
                      currentVal: _sensor.suhu,
                      maxVal:     40.0,
                    ),
                    const SizedBox(height: 12),

                    // ── Card pH + Ketinggian (2 kolom) ─────
                    Row(
                      children: [
                        Expanded(
                          child: _buildSensorCardHalf(
                            label:      'pH Air',
                            value:      _sensor.ph.toStringAsFixed(1),
                            unit:       '',
                            statusText: _getPhStatus(_sensor.ph),
                            icon:       Icons.science_outlined,
                            iconColor:  const Color(0xFF81C784),
                            valueColor: _getStatusColor(_getPhStatus(_sensor.ph)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSensorCardHalf(
                            label:      'Ketinggian Air',
                            value:      _sensor.ketinggian.toStringAsFixed(0),
                            unit:       'cm',
                            statusText: _getKetinggianStatus(_sensor.ketinggian),
                            icon:       Icons.water_outlined,
                            iconColor:  _C.blue,
                            valueColor: _getStatusColor(
                              _getKetinggianStatus(_sensor.ketinggian),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Card Pakan (full width) ────────────
                    _buildPakanCard(),
                    const SizedBox(height: 24),

                    // ── Aksi cepat ─────────────────────────
                    _buildSectionLabel('Aksi Cepat'),
                    const SizedBox(height: 12),
                    _buildAksiCepat(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD SIKLUS AKTIF + TOMBOL LIHAT DETAIL
  // ─────────────────────────────────────────────────
  Widget _buildSiklusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Baris atas: hari ke + info kolam ──────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hari ke
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Siklus Aktif',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ke $_hariKe',
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Kotak data kolam
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _C.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.kolam.totalIkan} ekor',
                      style: const TextStyle(
                        color: _C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target ${_targetHari}h · ${widget.kolam.targetBobot}kg',
                      style: TextStyle(
                        color: _C.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Progress bar siklus ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress siklus',
                style: TextStyle(
                  color: _C.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                '${(_progressSiklus * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: _C.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressSiklus,
              backgroundColor: _C.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(_C.blue),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),

          // ── Tombol Lihat Detail ────────────────────
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DetailKolamScreen(
                    user: widget.user,
                    kolam: widget.kolam,
                  ),
                ));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.white,
                side: const BorderSide(color: Colors.white38, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lihat Detail',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  BANNER STATUS KESELURUHAN
  // ─────────────────────────────────────────────────
  Widget _buildStatusBanner() {
    final isNormal = _sensor.isNormal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNormal
            ? _C.green.withValues(alpha: 0.1)
            : _C.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNormal
              ? _C.green.withValues(alpha: 0.3)
              : _C.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isNormal
                  ? _C.green.withValues(alpha: 0.15)
                  : _C.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNormal ? Icons.check_circle_outline : Icons.warning_amber,
              color: isNormal ? _C.green : _C.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNormal
                      ? 'Kondisi Kolam Normal'
                      : 'Ada Parameter Tidak Normal',
                  style: TextStyle(
                    color: isNormal ? _C.green : _C.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  isNormal
                      ? 'Semua parameter air dalam batas aman'
                      : 'Periksa parameter yang ditandai merah',
                  style: TextStyle(
                    color: isNormal
                        ? _C.green.withValues(alpha: 0.8)
                        : _C.warning.withValues(alpha: 0.8),
                    fontSize: 11,
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
  //  CARD SENSOR FULL WIDTH (Suhu)
  // ─────────────────────────────────────────────────
  Widget _buildSensorCardFull({
    required String label,
    required String value,
    required String unit,
    required String statusText,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
    required String rangeLabel,
    required double currentVal,
    required double maxVal,
  }) {
    final progress = (currentVal / maxVal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ikon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _C.subtext,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            color: valueColor,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            unit,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge status
              _buildStatusBadge(statusText),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rangeLabel,
                style: const TextStyle(color: _C.subtext, fontSize: 10),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _C.line,
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD SENSOR HALF WIDTH (pH & Ketinggian)
  // ─────────────────────────────────────────────────
  Widget _buildSensorCardHalf({
    required String label,
    required String value,
    required String unit,
    required String statusText,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
  }) {
    final isNormal = statusText == 'Normal';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + dot status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _C.subtext,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: isNormal ? _C.green : _C.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Ikon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),

          // Nilai + satuan
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD PAKAN
  // ─────────────────────────────────────────────────
  Widget _buildPakanCard() {
    // ⚠️ DUMMY — ganti dengan data dari JadwalPakanRepository nanti
    const double pakanTersisa  = 35.0;
    const double kapasitasMaks = 50.0;
    const String jadwalBerikut = '15.00 WIB';
    const int    jumlahGram    = 500;
    final double progressPakan =
        (pakanTersisa / kapasitasMaks).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ikon pakan
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.set_meal_outlined,
                  color: Color(0xFFFF8A65),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Nilai pakan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pakan',
                      style: TextStyle(
                        color: _C.subtext,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pakanTersisa.toStringAsFixed(0),
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            'kg tersisa',
                            style: TextStyle(
                              color: _C.subtext,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol beri pakan
              GestureDetector(
                onTap: _showPakanManualDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _C.navy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Beri Pakan',
                    style: TextStyle(
                      color: _C.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress stok pakan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa stok: ${pakanTersisa.toStringAsFixed(0)}kg / ${kapasitasMaks.toStringAsFixed(0)}kg',
                style: const TextStyle(color: _C.subtext, fontSize: 10),
              ),
              Text(
                '${(progressPakan * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: _C.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPakan,
              backgroundColor: _C.line,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF8A65),
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),

          // Info jadwal berikutnya
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_outlined, color: _C.subtext, size: 16),
                SizedBox(width: 8),
                Text(
                  'Jadwal berikutnya: $jadwalBerikut · $jumlahGram gram',
                  style: TextStyle(color: _C.subtext, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  AKSI CEPAT
  // ─────────────────────────────────────────────────
  Widget _buildAksiCepat() {
    return Row(
      children: [
        Expanded(
          child: _buildAksiItem(
            icon:  Icons.schedule_outlined,
            label: 'Jadwal\nPakan',
            color: _C.navy,
            onTap: () {
              // TODO: navigasi ke JadwalPakanScreen
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAksiItem(
            icon:  Icons.history_outlined,
            label: 'Riwayat\nData',
            color: _C.blue,
            onTap: () {
              // TODO: navigasi ke DataHistorisScreen
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAksiItem(
            icon:  Icons.devices_outlined,
            label: 'Status\nPerangkat',
            color: const Color(0xFF81C784),
            onTap: () {
              // TODO: navigasi ke PerangkatScreen
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAksiItem(
            icon:  Icons.notifications_none_outlined,
            label: 'Notifikasi',
            color: const Color(0xFFFF8A65),
            onTap: () {
              // TODO: navigasi ke NotifikasiScreen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAksiItem({
    required IconData icon,
    required String   label,
    required Color    color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.text,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  DIALOG PAKAN MANUAL
  // ─────────────────────────────────────────────────
  void _showPakanManualDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Beri Pakan Manual',
          style: TextStyle(
            color: _C.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin memberikan pakan sekarang?',
          style: TextStyle(color: _C.subtext, fontSize: 13),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Batal'),
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: panggil PakanController.beriPakanManual()
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Pakan berhasil diberikan'),
                    backgroundColor: _C.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.navy,
                foregroundColor: _C.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Ya'),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  HELPER WIDGETS
  // ─────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4, height: 18,
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
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(color: _C.subtext, fontSize: 10),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String label) {
    final isNormal = label == 'Normal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNormal
            ? _C.green.withValues(alpha: 0.12)
            : _C.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isNormal ? _C.green : _C.danger,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  HELPER STATUS & FORMAT
  // ─────────────────────────────────────────────────
  String _getSuhuStatus(double suhu) {
    if (suhu >= 26 && suhu <= 30) return 'Normal';
    if (suhu < 26) return 'Terlalu Rendah';
    return 'Terlalu Tinggi';
  }

  String _getPhStatus(double ph) {
    if (ph >= 6.5 && ph <= 8.5) return 'Normal';
    if (ph < 6.5) return 'Terlalu Asam';
    return 'Terlalu Basa';
  }

  String _getKetinggianStatus(double cm) {
    if (cm >= 60 && cm <= 120) return 'Normal';
    if (cm < 60) return 'Terlalu Rendah';
    return 'Terlalu Tinggi';
  }

  Color _getStatusColor(String status) {
    if (status == 'Normal') return _C.green;
    if (status.contains('Tinggi') || status.contains('Basa')) return _C.danger;
    return _C.warning;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h.$m WIB';
  }
}