// ═══════════════════════════════════════════════════════
//  jadwal_pakan_model.dart
// ═══════════════════════════════════════════════════════
class JadwalPakanModel {
  final String id;
  final String kolamId;
  final String jam;        // format "HH.mm"
  final int    jumlahGram;
  final bool   modeOtomatis;
 
  const JadwalPakanModel({
    required this.id,
    required this.kolamId,
    required this.jam,
    required this.jumlahGram,
    this.modeOtomatis = false,
  });
 
  factory JadwalPakanModel.fromMap(Map<String, dynamic> map) => JadwalPakanModel(
        id:           map['id']           ?? '',
        kolamId:      map['kolam_id']     ?? '',
        jam:          map['jam']          ?? '06.00',
        jumlahGram:   map['jumlah_gram']  ?? 0,
        modeOtomatis: map['mode_otomatis']?? false,
      );
 
  Map<String, dynamic> toMap() => {
        'kolam_id':      kolamId,
        'jam':           jam,
        'jumlah_gram':   jumlahGram,
        'mode_otomatis': modeOtomatis,
      };
}