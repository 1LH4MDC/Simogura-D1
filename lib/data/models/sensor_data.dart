// ═══════════════════════════════════════════════════════
//  sensor_model.dart
// ═══════════════════════════════════════════════════════
class SensorModel {
  final double   suhu;         // °C
  final double   ph;
  final double   amonia;       // ppm
  final double   ketinggian;   // cm
  final String   status;       // 'normal' | 'warning' | 'danger'
  final DateTime lastUpdated;
 
  const SensorModel({
    required this.suhu,
    required this.ph,
    required this.amonia,
    required this.ketinggian,
    required this.status,
    required this.lastUpdated,
  });
 
  bool get isNormal => status == 'normal';
 
  factory SensorModel.fromMap(Map<String, dynamic> map) => SensorModel(
        suhu:        (map['suhu']       as num).toDouble(),
        ph:          (map['ph']         as num).toDouble(),
        amonia:      (map['amonia']     as num).toDouble(),
        ketinggian:  (map['ketinggian'] as num).toDouble(),
        status:      map['status']      ?? 'normal',
        lastUpdated: DateTime.parse(map['last_updated']),
      );
}