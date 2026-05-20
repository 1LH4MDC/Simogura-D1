// ═══════════════════════════════════════════════════════
//  perangkat_model.dart
// ═══════════════════════════════════════════════════════
class PerangkatModel {
  final String id;
  final String kolamId;
  final String nama;
  final String tipe;      // 'jadwal_pakan' | 'water_pump' | dll
  final bool   isAktif;
 
  const PerangkatModel({
    required this.id,
    required this.kolamId,
    required this.nama,
    required this.tipe,
    this.isAktif = true,
  });
 
  factory PerangkatModel.fromMap(Map<String, dynamic> map) => PerangkatModel(
        id:      map['id']       ?? '',
        kolamId: map['kolam_id'] ?? '',
        nama:    map['nama']     ?? '',
        tipe:    map['tipe']     ?? '',
        isAktif: map['is_aktif'] ?? true,
      );
 
  Map<String, dynamic> toMap() => {
        'kolam_id': kolamId,
        'nama':     nama,
        'tipe':     tipe,
        'is_aktif': isAktif,
      };
}