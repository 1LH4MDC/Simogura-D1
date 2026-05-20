// ═══════════════════════════════════════════════════════
//  kolam_model.dart
// ═══════════════════════════════════════════════════════
class KolamModel {
  final String   id;
  final String   nama;
  final String   alamat;
  final int      totalIkan;
  final DateTime tanggalMulai;
  final double   targetBobot;
  final int      durasiTarget;
  final bool     status;

  const KolamModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.totalIkan,
    required this.tanggalMulai,
    required this.targetBobot,
    required this.durasiTarget,
    this.status = true,
  });

  factory KolamModel.fromMap(Map<String, dynamic> map) => KolamModel(
    id:           map['id']           as String? ?? '',
    nama:         map['nama']         as String? ?? '',
    alamat:       map['alamat']       as String? ?? '',
    totalIkan:    (map['total_ikan']  as num?)?.toInt()    ?? 0,
    targetBobot:  (map['target_bobot'] as num?)?.toDouble() ?? 0.0,
    durasiTarget: (map['durasi_target'] as num?)?.toInt()  ?? 0,
    status:       map['status']       as bool?  ?? true,

    // ✅ null-safe: pakai DateTime.now() kalau kolom kosong di DB
    tanggalMulai: map['tanggal_mulai'] != null
        ? DateTime.parse(map['tanggal_mulai'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'nama':          nama,
    'alamat':        alamat,
    'total_ikan':    totalIkan,
    'tanggal_mulai': tanggalMulai.toIso8601String(),
    'target_bobot':  targetBobot,
    'durasi_target': durasiTarget,
    'status':        status,
  };
}