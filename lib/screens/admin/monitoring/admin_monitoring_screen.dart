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

  // ── Config per sensor ──────────────────────────────
  final _labels = ['Suhu', 'PH', 'Amonia'];
  final _units  = ['°C', '', 'ppm'];
  final _icons  = [
    Icons.thermostat_outlined,
    Icons.science_outlined,
    Icons.waves_outlined,
  ];
  final _colors = [_C.blue, Color(0xFF81C784), Color(0xFFFFB74D)];

  // ✅ Data chart pakai x = index jam (0..6), bukan jam sebenarnya
  // Jam label ditampilkan manual di bawah
  final Map<int, List<FlSpot>> _chartData = {
    0: [ // Suhu: nilai sekitar 27-31
      FlSpot(0, 27.5), FlSpot(1, 28.0), FlSpot(2, 29.0),
      FlSpot(3, 30.2), FlSpot(4, 29.5), FlSpot(5, 28.8), FlSpot(6, 29.0),
    ],
    1: [ // pH: nilai sekitar 6.8-7.5
      FlSpot(0, 7.0), FlSpot(1, 7.1), FlSpot(2, 7.2),
      FlSpot(3, 7.0), FlSpot(4, 7.3), FlSpot(5, 7.2), FlSpot(6, 7.1),
    ],
    2: [ // Amonia: nilai sekitar 16-22
      FlSpot(0, 18), FlSpot(1, 19), FlSpot(2, 20),
      FlSpot(3, 21), FlSpot(4, 20), FlSpot(5, 19), FlSpot(6, 20),
    ],
  };

  // Label jam untuk X axis
  final _jamLabels = ['20.00','21.00','22.00','23.00','00.00','01.00','02.00'];

  final Map<int, Map<String, double>> _statData = {
    0: {'min': 27.5, 'avg': 28.9, 'max': 30.2},
    1: {'min': 7.0,  'avg': 7.13, 'max': 7.3},
    2: {'min': 18.0, 'avg': 19.6, 'max': 21.0},
  };

  // ✅ minY & maxY yang sempit agar grafik tidak pipih
  final Map<int, Map<String, double>> _chartRange = {
    0: {'min': 24.0, 'max': 34.0},   // Suhu
    1: {'min': 6.0,  'max': 8.5},    // pH
    2: {'min': 14.0, 'max': 26.0},   // Amonia
  };

  double get _currentValue {
    switch (_selectedSensor) {
      case 0: return widget.sensor.suhu;
      case 1: return widget.sensor.ph;
      default: return widget.sensor.amonia;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statData[_selectedSensor]!;
    final range = _chartRange[_selectedSensor]!;
    final color = _colors[_selectedSensor];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Card 3 gauge ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [_shadow()],
            ),
            child: Column(
              children: [
                const Text(
                  'Kondisi kolam Saat Ini',
                  style: TextStyle(
                    color: _C.subtext,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGauge(label:'Suhu',   value:widget.sensor.suhu,   unit:'°',   max:40, index:0),
                    _buildGauge(label:'PH',     value:widget.sensor.ph,     unit:'',    max:14, index:1),
                    _buildGauge(label:'Amonia', value:widget.sensor.amonia, unit:'ppm', max:50, index:2),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
                      _labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? _C.white : _C.subtext,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // ── Card Grafik ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [_shadow()],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Judul + label jam
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monitoring ${_labels[_selectedSensor]} Kolam',
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
                          Text('Jam',
                              style: TextStyle(color: _C.subtext, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              color: _C.subtext, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stat chips min / avg / max
                Row(
                  children: [
                    _buildStatChip(
                      'Min',
                      '${stats['min']} ${_units[_selectedSensor]}',
                      _C.blue.withValues(alpha: 0.12),
                      _C.blue,
                    ),
                    const SizedBox(width: 6),
                    _buildStatChip(
                      'Avg',
                      '${stats['avg']} ${_units[_selectedSensor]}',
                      _C.navy.withValues(alpha: 0.1),
                      _C.navy,
                    ),
                    const SizedBox(width: 6),
                    _buildStatChip(
                      'Max',
                      '${stats['max']} ${_units[_selectedSensor]}',
                      color.withValues(alpha: 0.12),
                      color,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ✅ Grafik dengan range Y yang sempit
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      // ✅ minX=0, maxX=6 (indeks), bukan jam
                      minX: 0,
                      maxX: 6,
                      // ✅ minY & maxY sempit agar grafik tampak jelas
                      minY: range['min']!,
                      maxY: range['max']!,

                      // Grid
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (range['max']! - range['min']!) / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: _C.line,
                          strokeWidth: 1,
                        ),
                      ),

                      // Border
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: _C.line, width: 1),
                          left:   BorderSide(color: _C.line, width: 1),
                        ),
                      ),

                      // Axis titles
                      titlesData: FlTitlesData(
                        // Y kiri — nilai sensor
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: (range['max']! - range['min']!) / 4,
                            getTitlesWidget: (v, _) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                v.toStringAsFixed(
                                  _selectedSensor == 1 ? 1 : 0,
                                ),
                                style: const TextStyle(
                                    color: _C.subtext, fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ),
                        // X bawah — jam
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: 1,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= _jamLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _jamLabels[idx],
                                  style: const TextStyle(
                                      color: _C.subtext, fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),

                      // Line data
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData[_selectedSensor]!,
                          isCurved: true,
                          curveSmoothness: 0.4,
                          color: color,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (s, x, bar, i) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeWidth: 2,
                              strokeColor: _C.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(alpha: 0.25),
                                color.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Tooltip
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipColor: (_) => _C.navy,
                          getTooltipItems: (spots) => spots.map((s) {
                            final idx = s.x.toInt().clamp(0, _jamLabels.length - 1);
                            return LineTooltipItem(
                              '${s.y.toStringAsFixed(_selectedSensor == 1 ? 1 : 0)}'
                              '${_units[_selectedSensor]}\n'
                              '${_jamLabels[idx]}',
                              const TextStyle(
                                color: _C.white,
                                fontSize: 11,
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
    final color    = _colors[index];

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
                // track
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 7,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _C.line,
                  ),
                ),
                // progress
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    active ? color : color.withValues(alpha: 0.4),
                  ),
                ),
                // teks nilai
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value.toStringAsFixed(
                            value % 1 == 0 ? 0 : 1),
                        style: TextStyle(
                          color: active ? _C.text : _C.subtext,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: unit,
                        style: TextStyle(
                          color: active ? _C.subtext : _C.line,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
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
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.7), fontSize: 9)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

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
  bool _jadwalExpanded = false;
  bool _pumpExpanded   = false;
  bool _modeOtomatis   = true;
  bool _pumpAktif      = true;

  // ⚠️ DUMMY — ganti dengan data JadwalPakanRepository
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
        children: [

          // ── Header kontrol ────────────────────────────
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
                const Text('Kontrol Perangkat',
                    style: TextStyle(
                        color: _C.text,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Kontrol perangkat IoT di ${widget.kolam.nama}',
                  style: const TextStyle(color: _C.subtext, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.navy,
                      foregroundColor: _C.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Perangkat',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Jadwal Pakan ──────────────────────────────
          _buildExpandableCard(
            icon: Icons.schedule_outlined,
            iconBg: _C.blue.withValues(alpha: 0.12),
            iconColor: _C.blue,
            title: 'Jadwal Pakan',
            badge: '${_jadwalList.length}x sehari',
            badgeColor: _C.green,
            isExpanded: _jadwalExpanded,
            onToggle: () =>
                setState(() => _jadwalExpanded = !_jadwalExpanded),
            content: _buildJadwalContent(),
          ),
          const SizedBox(height: 10),

          // ── Water Pump ────────────────────────────────
          _buildExpandableCard(
            icon: Icons.water_drop_outlined,
            iconBg: _C.blue.withValues(alpha: 0.12),
            iconColor: _C.blue,
            title: 'Water Pump',
            badge: _pumpAktif ? 'Aktif' : 'Tidak Aktif',
            badgeColor: _pumpAktif ? _C.green : _C.subtext,
            isExpanded: _pumpExpanded,
            onToggle: () =>
                setState(() => _pumpExpanded = !_pumpExpanded),
            content: _buildPumpContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData  icon,
    required Color     iconBg,
    required Color     iconColor,
    required String    title,
    required String    badge,
    required Color     badgeColor,
    required bool      isExpanded,
    required VoidCallback onToggle,
    required Widget    content,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [_shadow()],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: _C.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
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
          if (isExpanded) ...[
            Divider(color: _C.line, height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJadwalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mode Otomatis',
                style: TextStyle(
                    color: _C.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            Switch(
              value: _modeOtomatis,
              onChanged: (v) => setState(() => _modeOtomatis = v),
              activeColor: _C.navy,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._jadwalList.asMap().entries.map((e) {
          final i    = e.key;
          final item = e.value;
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
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: _C.subtext),
                      const SizedBox(width: 6),
                      Text(item['label'],
                          style: const TextStyle(
                              color: _C.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ]),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _jadwalList.removeAt(i)),
                      child: const Icon(Icons.delete_outline,
                          color: _C.subtext, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _buildJadwalField('Jam', item['jam']),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildJadwalField('Jumlah (gram)', item['gram']),
                  ),
                ]),
              ],
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Jadwal berhasil disimpan'),
                backgroundColor: _C.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.navy,
              foregroundColor: _C.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Simpan Perubahan',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _C.subtext, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value,
              style: const TextStyle(color: _C.text, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildPumpContent() {
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
              const Text('Water Pump',
                  style: TextStyle(
                      color: _C.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text(
                _pumpAktif ? 'Sedang berjalan' : 'Tidak aktif',
                style: const TextStyle(color: _C.subtext, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: _pumpAktif,
          onChanged: (v) => setState(() => _pumpAktif = v),
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