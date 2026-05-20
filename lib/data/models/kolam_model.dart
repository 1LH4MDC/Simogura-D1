// ═══════════════════════════════════════════════════════
//  kolam_model.dart
// ═══════════════════════════════════════════════════════
class KolamModel {
  final String   id;
  final String   nama;
  final String   alamat;
  final int      totalIkan;      // ekor
  final DateTime tanggalMulai;
  final double   targetBobot;    // kg
  final int      durasiTarget;   // hari
  final bool     isAktif;
 
  const KolamModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.totalIkan,
    required this.tanggalMulai,
    required this.targetBobot,
    required this.durasiTarget,
    this.isAktif = true,
  });
 
  factory KolamModel.fromMap(Map<String, dynamic> map) => KolamModel(
        id:           map['id']           ?? '',
        nama:         map['nama']         ?? '',
        alamat:       map['alamat']       ?? '',
        totalIkan:    map['total_ikan']   ?? 0,
        tanggalMulai: DateTime.parse(map['tanggal_mulai']),
        targetBobot:  (map['target_bobot'] as num).toDouble(),
        durasiTarget: map['durasi_target'] ?? 0,
        isAktif:      map['is_aktif']     ?? true,
      );
 
  Map<String, dynamic> toMap() => {
        'nama':          nama,
        'alamat':        alamat,
        'total_ikan':    totalIkan,
        'tanggal_mulai': tanggalMulai.toIso8601String(),
        'target_bobot':  targetBobot,
        'durasi_target': durasiTarget,
        'is_aktif':      isAktif,
      };
}