// ═══════════════════════════════════════════════════════
//  siklus_model.dart
// ═══════════════════════════════════════════════════════
class SiklusModel {
  final String  id;
  final String  kolamId;
  final int     hariKe;
  final int     targetHari;
  final int?    populasiAkhir;
  final double? bobotAkhir;
  final double? totalKonsumsiPakan; // gram
  final bool    selesai;
 
  const SiklusModel({
    required this.id,
    required this.kolamId,
    required this.hariKe,
    required this.targetHari,
    this.populasiAkhir,
    this.bobotAkhir,
    this.totalKonsumsiPakan,
    this.selesai = false,
  });
 
  factory SiklusModel.fromMap(Map<String, dynamic> map) => SiklusModel(
        id:                 map['id']         ?? '',
        kolamId:            map['kolam_id']   ?? '',
        hariKe:             map['hari_ke']    ?? 0,
        targetHari:         map['target_hari']?? 0,
        populasiAkhir:      map['populasi_akhir'],
        bobotAkhir:         map['bobot_akhir'] != null
            ? (map['bobot_akhir'] as num).toDouble()
            : null,
        totalKonsumsiPakan: map['total_konsumsi_pakan'] != null
            ? (map['total_konsumsi_pakan'] as num).toDouble()
            : null,
        selesai: map['selesai'] ?? false,
      );
 
  Map<String, dynamic> toMap() => {
        'kolam_id':            kolamId,
        'hari_ke':             hariKe,
        'target_hari':         targetHari,
        'populasi_akhir':      populasiAkhir,
        'bobot_akhir':         bobotAkhir,
        'total_konsumsi_pakan':totalKonsumsiPakan,
        'selesai':             selesai,
      };
}