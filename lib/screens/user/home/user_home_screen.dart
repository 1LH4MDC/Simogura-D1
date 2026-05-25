import 'package:flutter/material.dart';
import '../../../controllers/kolam_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/kolam_model.dart';
import '../../../data/models/sensor_model.dart';
import '../../../navigation/user_bottom_nav.dart';

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
//  USER HOME SCREEN
//
//  Mode 1 — kolam == null (dari AppRouter)
//    → Tampil daftar kolam → user pilih → masuk UserBottomNav
//
//  Mode 2 — kolam != null (dari UserBottomNav tab Home)
//    → Tampil dashboard readonly kolam yang sudah dipilih
// ─────────────────────────────────────────────────────────────
class UserHomeScreen extends StatefulWidget {
  final UserModel   user;
  final KolamModel? kolam; // ← null = pilih kolam, ada = dashboard kolam

  const UserHomeScreen({
    super.key,
    required this.user,
    this.kolam,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _kolamController = KolamController();

  List<KolamModel>             _kolams    = [];
  bool                         _isLoading = true;
  final Map<String, SensorModel> _sensorMap = {};

  @override
  void initState() {
    super.initState();
    // Mode 1 saja yang perlu fetch — mode 2 pakai widget.kolam
    if (widget.kolam == null) _fetchKolams();
  }

  Future<void> _fetchKolams() async {
    setState(() => _isLoading = true);
    try {
      final data = await _kolamController.getKolams();
      setState(() => _kolams = data);

      // ⚠️ DUMMY sensor — ganti dengan SensorRepository nanti
      for (final k in data) {
        _sensorMap[k.id] = SensorModel(
          suhu:        27 + (_kolams.indexOf(k) * 1.5),
          ph:          7.0 + (_kolams.indexOf(k) * 0.2),
          amonia:      18.0 + (_kolams.indexOf(k) * 2),
          ketinggian:  80.0,
          status:      _kolams.indexOf(k) == 1 ? 'warning' : 'normal',
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('FETCH_KOLAM_USER_ERROR: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pilihKolam(KolamModel kolam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserBottomNav(
          user:  widget.user,
          kolam: kolam, // ✅ pakai parameter kolam, bukan widget.kolam
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  BUILD — pilih mode
  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Mode 2: sudah ada kolam → tampil dashboard readonly
    if (widget.kolam != null) {
      return _buildDashboardMode(widget.kolam!);
    }
    // Mode 1: belum pilih kolam → tampil daftar
    return _buildPilihKolamMode();
  }

  // ═══════════════════════════════════════════════════
  //  MODE 1 — PILIH KOLAM
  // ═══════════════════════════════════════════════════
  Widget _buildPilihKolamMode() {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
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
    );
  }

  // ═══════════════════════════════════════════════════
  //  MODE 2 — DASHBOARD READONLY
  // ═══════════════════════════════════════════════════
  Widget _buildDashboardMode(KolamModel kolam) {
    // ⚠️ DUMMY sensor untuk kolam ini
    // Nanti ganti dengan SensorRepository().getLatest(kolam.id)
    final sensor = SensorModel(
      suhu:        29.0,
      ph:          7.2,
      amonia:      20.0,
      ketinggian:  85.0,
      status:      'normal',
      lastUpdated: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: _C.navy,
              foregroundColor: _C.white,
              pinned: true,
              automaticallyImplyLeading: false, // Tetap false agar kita bisa pakai 'leading' custom
              
              // ✅ Tambahkan widget leading ini untuk tombol KEMBALI
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: _C.white),
                onPressed: () {
                  // Menutup halaman dashboard (UserBottomNav) dan kembali ke list
                  Navigator.pop(context); 
                },
              ),
              
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    kolam.nama,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    kolam.alamat,
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
                      icon: const Icon(
                        Icons.notifications_none,
                        color: _C.white,
                      ),
                      onPressed: () {},
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

                    // ── Banner status ──────────────────────
                    _buildStatusBanner(sensor.isNormal),
                    const SizedBox(height: 16),

                    // ── Label monitoring ───────────────────
                    _buildSectionLabel(
                      'Monitoring Real-Time',
                      subtitle: 'Diperbarui: ${_formatTime(sensor.lastUpdated)}',
                    ),
                    const SizedBox(height: 12),

                    // ── Card Suhu (full) ───────────────────
                    _buildSensorCardFull(
                      label:      'Suhu Air',
                      value:      sensor.suhu.toStringAsFixed(1),
                      unit:       '°C',
                      statusText: _getSuhuStatus(sensor.suhu),
                      icon:       Icons.thermostat_outlined,
                      iconColor:  const Color(0xFF4FC3F7),
                      valueColor: _getStatusColor(_getSuhuStatus(sensor.suhu)),
                      rangeLabel: 'Normal: 26°C – 30°C',
                      currentVal: sensor.suhu,
                      maxVal:     40.0,
                    ),
                    const SizedBox(height: 12),

                    // ── Card pH + Ketinggian (2 kolom) ─────
                    Row(
                      children: [
                        Expanded(
                          child: _buildSensorCardHalf(
                            label:      'pH Air',
                            value:      sensor.ph.toStringAsFixed(1),
                            unit:       '',
                            statusText: _getPhStatus(sensor.ph),
                            icon:       Icons.science_outlined,
                            iconColor:  const Color(0xFF81C784),
                            valueColor: _getStatusColor(
                                _getPhStatus(sensor.ph)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSensorCardHalf(
                            label:      'Ketinggian Air',
                            value:      sensor.ketinggian.toStringAsFixed(0),
                            unit:       'cm',
                            statusText: _getKetinggianStatus(
                                sensor.ketinggian),
                            icon:       Icons.water_outlined,
                            iconColor:  _C.blue,
                            valueColor: _getStatusColor(
                                _getKetinggianStatus(sensor.ketinggian)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Card Amonia (full) ─────────────────
                    _buildSensorCardFull(
                      label:      'Kadar Amonia',
                      value:      sensor.amonia.toStringAsFixed(1),
                      unit:       'ppm',
                      statusText: _getAmoniaStatus(sensor.amonia),
                      icon:       Icons.waves_outlined,
                      iconColor:  const Color(0xFFFFB74D),
                      valueColor: _getStatusColor(
                          _getAmoniaStatus(sensor.amonia)),
                      rangeLabel: 'Normal: < 25 ppm',
                      currentVal: sensor.amonia,
                      maxVal:     50.0,
                    ),
                    const SizedBox(height: 24),

                    // ── Info kolam ─────────────────────────
                    _buildSectionLabel('Info Kolam'),
                    const SizedBox(height: 12),
                    _buildInfoKolam(kolam),
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
  //  HEADER (Mode 1)
  // ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _C.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (widget.user.username ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: _C.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hallo, ${widget.user.username ?? "Petugas"}',
                  style: const TextStyle(
                    color: _C.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Petugas Lapangan',
                  style: TextStyle(color: _C.subtext, fontSize: 12),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 42, height: 42,
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
    );
  }

  // ─────────────────────────────────────────────────
  //  LIST KOLAM (Mode 1)
  // ─────────────────────────────────────────────────
  Widget _buildKolamList() {
    final totalKolam   = _kolams.length;
    final kolamNormal  = _kolams.where((k) =>
        (_sensorMap[k.id]?.isNormal ?? true)).length;
    final kolamWarning = totalKolam - kolamNormal;

    return RefreshIndicator(
      onRefresh: _fetchKolams,
      color: _C.navy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              totalKolam:   totalKolam,
              kolamNormal:  kolamNormal,
              kolamWarning: kolamWarning,
            ),
            const SizedBox(height: 20),
            Row(
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
                    const Text(
                      'Daftar Kolam',
                      style: TextStyle(
                        color: _C.text,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$totalKolam kolam',
                  style: const TextStyle(color: _C.subtext, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _kolams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final kolam  = _kolams[i];
                final sensor = _sensorMap[kolam.id];
                return _buildKolamCard(kolam, sensor);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD SUMMARY (Mode 1)
  // ─────────────────────────────────────────────────
  Widget _buildSummaryCard({
    required int totalKolam,
    required int kolamNormal,
    required int kolamWarning,
  }) {
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
          const Text('Ringkasan Kolam',
              style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '$totalKolam Kolam Terdaftar',
            style: const TextStyle(
              color: _C.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatusChip(
                icon:  Icons.check_circle_outline,
                label: '$kolamNormal Normal',
                color: _C.green,
              ),
              const SizedBox(width: 10),
              if (kolamWarning > 0)
                _buildStatusChip(
                  icon:  Icons.warning_amber,
                  label: '$kolamWarning Perlu Perhatian',
                  color: _C.warning,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                'Terakhir diperbarui: ${_formatTime(DateTime.now())}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String   label,
    required Color    color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  CARD KOLAM (Mode 1)
  // ─────────────────────────────────────────────────
  Widget _buildKolamCard(KolamModel kolam, SensorModel? sensor) {
    final isNormal    = sensor?.isNormal ?? true;
    final statusText  = isNormal ? 'Normal' : 'Tidak Normal';
    final statusColor = isNormal ? _C.green : _C.warning;

    return GestureDetector(
      onTap: () => _pilihKolam(kolam),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: isNormal
              ? null
              : Border.all(
                  color: _C.warning.withValues(alpha: 0.4),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _C.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.waves, color: _C.navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kolam.nama,
                            style: const TextStyle(
                                color: _C.text,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(kolam.alamat,
                            style: const TextStyle(
                                color: _C.subtext, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${kolam.totalIkan} ekor · Target ${kolam.durasiTarget} hari',
                          style: const TextStyle(
                              color: _C.subtext, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.chevron_right,
                          color: _C.subtext, size: 18),
                    ],
                  ),
                ],
              ),
            ),

            // Mini sensor row
            if (sensor != null) ...[
              Divider(color: _C.line, height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniSensor(
                      icon:  Icons.thermostat_outlined,
                      color: const Color(0xFF4FC3F7),
                      label: 'Suhu',
                      value: '${sensor.suhu.toStringAsFixed(1)}°C',
                    ),
                    _buildDividerV(),
                    _buildMiniSensor(
                      icon:  Icons.science_outlined,
                      color: const Color(0xFF81C784),
                      label: 'pH',
                      value: sensor.ph.toStringAsFixed(1),
                    ),
                    _buildDividerV(),
                    _buildMiniSensor(
                      icon:  Icons.waves_outlined,
                      color: _C.blue,
                      label: 'Amonia',
                      value: '${sensor.amonia.toStringAsFixed(0)} ppm',
                    ),
                    _buildDividerV(),
                    _buildMiniSensor(
                      icon:  Icons.water_outlined,
                      color: _C.blue,
                      label: 'Tinggi',
                      value: '${sensor.ketinggian.toStringAsFixed(0)} cm',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSensor({
    required IconData icon,
    required Color    color,
    required String   label,
    required String   value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: _C.text,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        Text(label,
            style: const TextStyle(color: _C.subtext, fontSize: 10)),
      ],
    );
  }

  Widget _buildDividerV() =>
      Container(width: 1, height: 36, color: _C.line);

  // ─────────────────────────────────────────────────
  //  EMPTY STATE (Mode 1)
  // ─────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: _C.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.waves_outlined,
                  size: 48, color: _C.subtext),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Kolam',
                style: TextStyle(
                    color: _C.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Hubungi admin untuk menambahkan\nkolam ke dalam sistem',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _C.subtext, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _fetchKolams,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Muat Ulang'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.navy,
                side: const BorderSide(color: _C.navy),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  WIDGETS MODE 2 — DASHBOARD READONLY
  // ─────────────────────────────────────────────────
  Widget _buildStatusBanner(bool isNormal) {
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
                      : 'Segera laporkan ke admin',
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

  Widget _buildSensorCardFull({
    required String   label,
    required String   value,
    required String   unit,
    required String   statusText,
    required IconData icon,
    required Color    iconColor,
    required Color    valueColor,
    required String   rangeLabel,
    required double   currentVal,
    required double   maxVal,
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
                    Text(label,
                        style: const TextStyle(
                            color: _C.subtext,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(value,
                            style: TextStyle(
                                color: valueColor,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                height: 1)),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(unit,
                              style: TextStyle(
                                  color: valueColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(statusText),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rangeLabel,
                  style: const TextStyle(
                      color: _C.subtext, fontSize: 10)),
              Text(statusText,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
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

  Widget _buildSensorCardHalf({
    required String   label,
    required String   value,
    required String   unit,
    required String   statusText,
    required IconData icon,
    required Color    iconColor,
    required Color    valueColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _C.subtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
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
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                        color: valueColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(statusText,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoKolam(KolamModel kolam) {
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
        children: [
          _infoRow(Icons.waves,              'Nama Kolam',    kolam.nama),
          _divider(),
          _infoRow(Icons.location_on_outlined,'Alamat',       kolam.alamat),
          _divider(),
          _infoRow(Icons.set_meal_outlined,  'Total Ikan',
              '${kolam.totalIkan} ekor'),
          _divider(),
          _infoRow(Icons.timer_outlined,     'Durasi Target',
              '${kolam.durasiTarget} hari'),
          _divider(),
          _infoRow(Icons.monitor_weight_outlined, 'Target Bobot',
              '${kolam.targetBobot} kg'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: _C.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: _C.navy, size: 17),
            ),
            const SizedBox(width: 12),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _divider() =>
      Divider(color: _C.line, height: 1, thickness: 1);

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
            Text(title,
                style: const TextStyle(
                    color: _C.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        if (subtitle != null)
          Text(subtitle,
              style: const TextStyle(color: _C.subtext, fontSize: 10)),
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
      child: Text(label,
          style: TextStyle(
              color: isNormal ? _C.green : _C.danger,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  // ─────────────────────────────────────────────────
  //  STATUS HELPERS
  // ─────────────────────────────────────────────────
  String _getSuhuStatus(double v) {
    if (v >= 26 && v <= 30) return 'Normal';
    return v < 26 ? 'Terlalu Rendah' : 'Terlalu Tinggi';
  }

  String _getPhStatus(double v) {
    if (v >= 6.5 && v <= 8.5) return 'Normal';
    return v < 6.5 ? 'Terlalu Asam' : 'Terlalu Basa';
  }

  String _getKetinggianStatus(double v) {
    if (v >= 60 && v <= 120) return 'Normal';
    return v < 60 ? 'Terlalu Rendah' : 'Terlalu Tinggi';
  }

  String _getAmoniaStatus(double v) {
    if (v < 25) return 'Normal';
    return v < 35 ? 'Peringatan' : 'Berbahaya';
  }

  Color _getStatusColor(String status) {
    if (status == 'Normal') return _C.green;
    if (status == 'Peringatan' || status.contains('Rendah') ||
        status.contains('Asam')) return _C.warning;
    return _C.danger;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h.$m WIB';
  }
}