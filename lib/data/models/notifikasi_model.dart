// ═══════════════════════════════════════════════════════
//  notifikasi_model.dart
// ═══════════════════════════════════════════════════════
class NotifikasiModel {
  final String   id;
  final String   kolamId;
  final String   pesan;
  final String   tipe;     // 'suhu' | 'ph' | 'amonia' | 'ketinggian'
  final bool     isRead;
  final DateTime timestamp;
 
  const NotifikasiModel({
    required this.id,
    required this.kolamId,
    required this.pesan,
    required this.tipe,
    this.isRead = false,
    required this.timestamp,
  });
 
  factory NotifikasiModel.fromMap(Map<String, dynamic> map) => NotifikasiModel(
        id:        map['id']        ?? '',
        kolamId:   map['kolam_id']  ?? '',
        pesan:     map['pesan']     ?? '',
        tipe:      map['tipe']      ?? '',
        isRead:    map['is_read']   ?? false,
        timestamp: DateTime.parse(map['timestamp']),
      );
}