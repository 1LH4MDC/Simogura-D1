import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:simogura/data/models/sensor_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/kolam_model.dart';


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
  static const green   = Color(0xFF4CAF50);
  static const warning = Color(0xFFF4A623);
  static const danger  = Color(0xFFE53935);
}

// ─────────────────────────────────────────────────────────────
//  ADMIN MONITORING SCREEN
// ─────────────────────────────────────────────────────────────
class AdminMonitoringScreen extends StatefulWidget {
  final UserModel  user;
  final KolamModel kolam;

  const AdminMonitoringScreen({
    super.key,
    required this.user,
    required this.kolam,
  });

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // ⚠️ DATA DUMMY — ganti dengan stream SensorRepository nanti
  final SensorModel _sensor = SensorModel(
    suhu:        29.0,
    ph:          7.2,
    amonia:      20.0,
    ketinggian:  85.0,
    status:      'normal',
    lastUpdated: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Monitoring',
          style: TextStyle(
            color: _C.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: _C.navy),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _C.navy,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: _C.white,
                unselectedLabelColor: _C.subtext,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.show_chart, size: 16),
                        SizedBox(width: 6),
                        Text('Sensor'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, size: 16),
                        SizedBox(width: 6),
                        Text('Perangkat'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SensorTab(sensor: _sensor, kolam: widget.kolam),
          _PerangkatTab(kolam: widget.kolam),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TAB 1 — SENSOR
// ═════════════════════════════════════════════════════════════
class _SensorTab extends StatefulWidget {
  final SensorModel sensor;
  final KolamModel  kolam;

  const _SensorTab({required this.sensor, required this.kolam});

  @override
  State<_SensorTab> createState() => _SensorTabState();
}

class _SensorTabState extends State<_SensorTab> {
  int _selectedSensor = 0; // 0=Suhu, 1=PH, 2=Amonia

  final _sensorLabels = ['Suhu', 'PH', 'Amonia'];

  // ⚠️ DUMMY grafik — ganti dengan data historis dari SensorRepository
  final Map<int, List<FlSpot>> _chartData = {
    0: [
      FlSpot(20, 27), FlSpot(21, 28), FlSpot(22, 29),
      FlSpot(23, 30), FlSpot(0,  29), FlSpot(1,  28), FlSpot(2,  29),
    ],
    1: [
      FlSpot(20, 7.0), FlSpot(21, 7.1), FlSpot(22, 7.2),
      FlSpot(23, 7.0), FlSpot(0,  7.3), FlSpot(1,  7.2), FlSpot(2,  7.1),
    ],
    2: [
      FlSpot(20, 18), FlSpot(21, 19), FlSpot(22, 20),
      FlSpot(23, 21), FlSpot(0,  20), FlSpot(1,  19), FlSpot(2,  20),
    ],
  };

  final Map<int, Map<String, double>> _statData = {
    0: {'min': 27.0, 'avg': 28.5, 'max': 30.0},
    1: {'min': 7.0,  'avg': 7.15, 'max': 7.3},
    2: {'min': 18.0, 'avg': 19.5, 'max': 21.0},
  };

  double get _currentValue {
    switch (_selectedSensor) {
      case 0: return widget.sensor.suhu;
      case 1: return widget.sensor.ph;
      default: return widget.sensor.amonia;
    }
  }

  String get _currentUnit {
    switch (_selectedSensor) {
      case 0: return '°C';
      case 1: return '';
      default: return 'ppm';
    }
  }

  Color get _gaugeColor => _C.blue;

  double get _gaugeMax {
    switch (_selectedSensor) {
      case 0: return 40.0;
      case 1: return 14.0;
      default: return 50.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statData[_selectedSensor]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Card 3 gauge ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [_shadow()],
            ),
            child: Column(
              children: [
                Text(
                  'Kondisi Kolam Saat Ini',
                  style: TextStyle(
                    color: _C.text.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGauge(
                      label: 'Suhu',
                      value: widget.sensor.suhu,
                      unit: '°',
                      max: 40,
                      index: 0,
                    ),
                    _buildGauge(
                      label: 'PH',
                      value: widget.sensor.ph,
                      unit: '',
                      max: 14,
                      index: 1,
                    ),
                    _buildGauge(
                      label: 'Amonia',
                      value: widget.sensor.amonia,
                      unit: 'ppm',
                      max: 50,
                      index: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Selector Suhu / PH / Amonia ──────────────
          Row(
            children: List.generate(3, (i) {
              final active = _selectedSensor == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSensor = i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: active ? _C.navy : _C.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [_shadow()],
                    ),
                    child: Text(
                      _sensorLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? _C.white : _C.subtext,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Card grafik ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [_shadow()],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul + dropdown jam
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monitoring ${_sensorLabels[_selectedSensor]} Kolam',
                      style: const TextStyle(
                        color: _C.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: _C.line),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Jam',
                            style: TextStyle(
                                color: _C.subtext, fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              color: _C.subtext, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stat min/avg/max
                Row(
                  children: [
                    _buildStatChip(
                        'Min : ${stats['min']} ${_currentUnit}'),
                    const SizedBox(width: 6),
                    _buildStatChip(
                        'Avg : ${stats['avg']} ${_currentUnit}'),
                    const SizedBox(width: 6),
                    _buildStatChip(
                        'Max : ${stats['max']} ${_currentUnit}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Y-axis labels + grafik
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: _gaugeMax / 9,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: _C.line,
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (v) => FlLine(
                          color: _C.line,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: _gaugeMax / 9,
                            getTitlesWidget: (v, _) => Text(
                              v.toStringAsFixed(0),
                              style: const TextStyle(
                                  color: _C.subtext, fontSize: 9),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            interval: 1,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt().toString().padLeft(2, '0')}.00',
                              style: const TextStyle(
                                  color: _C.subtext, fontSize: 8),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 20,
                      maxX: 2,
                      minY: 0,
                      maxY: _gaugeMax,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData[_selectedSensor]!,
                          isCurved: true,
                          color: _C.green,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (s, x, bar, i) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: _C.green,
                              strokeWidth: 1.5,
                              strokeColor: _C.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _C.green.withValues(alpha: 0.2),
                                _C.green.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots.map((s) {
                            return LineTooltipItem(
                              '${s.y.toStringAsFixed(1)}$_currentUnit\n'
                              '${s.x.toInt().toString().padLeft(2, '0')}.00',
                              const TextStyle(
                                color: _C.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Gauge circular ────────────────────────────────
  Widget _buildGauge({
    required String label,
    required double value,
    required String unit,
    required double max,
    required int index,
  }) {
    final progress = (value / max).clamp(0.0, 1.0);
    final active   = _selectedSensor == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedSensor = index),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background arc
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 7,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_C.line),
                ),
                // Progress arc
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    active ? _C.blue : _C.blue.withValues(alpha: 0.5),
                  ),
                ),
                // Nilai
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: value.toStringAsFixed(
                                value % 1 == 0 ? 0 : 1),
                            style: TextStyle(
                              color: _C.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: unit,
                            style: const TextStyle(
                              color: _C.subtext,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? _C.navy : _C.subtext,
              fontSize: 12,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(color: _C.subtext, fontSize: 10),
        ),
      );

  BoxShadow _shadow() => BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );
}

// ═════════════════════════════════════════════════════════════
//  TAB 2 — PERANGKAT
// ═════════════════════════════════════════════════════════════
class _PerangkatTab extends StatefulWidget {
  final KolamModel kolam;
  const _PerangkatTab({required this.kolam});

  @override
  State<_PerangkatTab> createState() => _PerangkatTabState();
}

class _PerangkatTabState extends State<_PerangkatTab> {

  bool _jadwalExpanded  = false;
  bool _pumpExpanded    = false;
  bool _modeOtomatis    = true;
  bool _pumpAktif       = true;

  // ⚠️ DUMMY jadwal pakan — ganti dengan data JadwalPakanRepository
  final List<Map<String, dynamic>> _jadwalList = [
    {'label': 'Jadwal 2', 'jam': '06.00', 'gram': '2000'},
    {'label': 'Jadwal 3', 'jam': '12.00', 'gram': '2000'},
    {'label': 'Jadwal 4', 'jam': '18.00', 'gram': '2000'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Card header kontrol perangkat ─────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [_shadow()],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontrol Perangkat',
                  style: TextStyle(
                    color: _C.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kontrol perangkat IoT di ${widget.kolam.nama}',
                  style:
                      const TextStyle(color: _C.subtext, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigasi ke TambahPerangkatScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: _C.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Tambah Perangkat',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Card Jadwal Pakan (expandable) ────────────
          _buildExpandableCard(
            icon: Icons.schedule_outlined,
            iconColor: _C.blue,
            title: 'Jadwal Pakan',
            badge: '${_jadwalList.length} x sehari',
            badgeColor: _C.green,
            isExpanded: _jadwalExpanded,
            onToggle: () =>
                setState(() => _jadwalExpanded = !_jadwalExpanded),
            expandedContent: _buildJadwalContent(),
          ),
          const SizedBox(height: 10),

          // ── Card Water Pump (expandable) ──────────────
          _buildExpandableCard(
            icon: Icons.water_drop_outlined,
            iconColor: _C.blue,
            title: 'Water Pump',
            badge: _pumpAktif ? 'Aktif' : 'Tidak Aktif',
            badgeColor: _pumpAktif ? _C.green : _C.subtext,
            isExpanded: _pumpExpanded,
            onToggle: () =>
                setState(() => _pumpExpanded = !_pumpExpanded),
            expandedContent: _buildWaterPumpContent(),
          ),
        ],
      ),
    );
  }

  // ── Expandable card template ──────────────────────
  Widget _buildExpandableCard({
    required IconData icon,
    required Color    iconColor,
    required String   title,
    required String   badge,
    required Color    badgeColor,
    required bool     isExpanded,
    required VoidCallback onToggle,
    required Widget   expandedContent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [_shadow()],
      ),
      child: Column(
        children: [
          // ── Header baris ────────────────────────────
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ikon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // judul + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // chevron
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: _C.subtext,
                  ),
                ],
              ),
            ),
          ),

          // ── Konten expandable ────────────────────────
          if (isExpanded) ...[
            Divider(color: _C.line, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: expandedContent,
            ),
          ],
        ],
      ),
    );
  }

  // ── Konten jadwal pakan ───────────────────────────
  Widget _buildJadwalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode otomatis toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mode Otomatis',
              style: TextStyle(
                color: _C.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: _modeOtomatis,
              onChanged: (v) => setState(() => _modeOtomatis = v),
              activeColor: _C.navy,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List jadwal
        ..._jadwalList.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _C.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: _C.subtext,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['label'],
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _jadwalList.removeAt(i));
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: _C.subtext,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jam',
                            style: TextStyle(
                                color: _C.subtext, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _C.bg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['jam'],
                              style: const TextStyle(
                                color: _C.text,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jumlah (gram)',
                            style: TextStyle(
                                color: _C.subtext, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _C.bg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['gram'],
                              style: const TextStyle(
                                color: _C.text,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        // Tombol simpan perubahan
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              // TODO: simpan jadwal ke JadwalPakanRepository
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Jadwal berhasil disimpan'),
                  backgroundColor: _C.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.navy,
              foregroundColor: _C.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Simpan Perubahan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // ── Konten water pump ─────────────────────────────
  Widget _buildWaterPumpContent() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _C.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.water_drop_outlined,
              color: _C.blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Water Pump',
                style: TextStyle(
                    color: _C.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                _pumpAktif ? 'Sedang berjalan' : 'Tidak aktif',
                style:
                    const TextStyle(color: _C.subtext, fontSize: 12),
              ),
            ],
          ),
        ),
        // Toggle pump
        Switch(
          value: _pumpAktif,
          onChanged: (v) {
            setState(() => _pumpAktif = v);
            // TODO: kirim perintah ke perangkat IoT
          },
          activeColor: _C.navy,
        ),
      ],
    );
  }

  BoxShadow _shadow() => BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );
}