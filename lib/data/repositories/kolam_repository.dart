import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kolam_model.dart';

// ─────────────────────────────────────────────────────────────
//  KOLAM REPOSITORY
// ─────────────────────────────────────────────────────────────
class KolamRepository {
  final _db = Supabase.instance.client;

  // ── Fetch SEMUA kolam (tanpa filter userId) ────────────────
  Future<List<KolamModel>> getKolams() async { // ✅ Hapus parameter userId
    final response = await _db
        .from('kolam')
        .select()
        // ❌ Hapus baris .eq('created_by', userId) agar semua kolam terbaca
        .order('created_at', ascending: false);

    return (response as List).map((e) => KolamModel.fromMap(e)).toList();
  }

  // ── Fetch satu kolam berdasarkan id ────────────────
  Future<KolamModel?> getKolamById(String id) async {
    final response = await _db
        .from('kolam')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return KolamModel.fromMap(response);
  }

  // ── Tambah kolam baru ──────────────────────────────
  Future<KolamModel> createKolam({
    required String nama,
    required String alamat,
    required int totalIkan,
    required DateTime tanggalMulai,
    required double targetBobot,
    required int durasiTarget,
    required int userId,
  }) async {
    final response = await _db
        .from('kolam')
        .insert({
          'nama': nama,
          'alamat': alamat,
          'total_ikan': totalIkan,
          'tanggal_mulai': tanggalMulai.toIso8601String(),
          'target_bobot': targetBobot,
          'durasi_target': durasiTarget,
          'status': true,
          'created_by': userId,
        })
        .select()
        .single();

    return KolamModel.fromMap(response);
  }

  // ── Update kolam ───────────────────────────────────
  Future<void> updateKolam({
    required String id,
    required String nama,
    required String alamat,
    required int totalIkan,
    required double targetBobot,
    required int durasiTarget,
  }) async {
    await _db
        .from('kolam')
        .update({
          'nama': nama,
          'alamat': alamat,
          'total_ikan': totalIkan,
          'target_bobot': targetBobot,
          'durasi_target': durasiTarget,
        })
        .eq('id', id);
  }

  // ── Selesaikan kolam (is_aktif = false) ───────────
  Future<void> selesaikanKolam(String id) async {
    await _db.from('kolam').update({'is_aktif': false}).eq('id', id);
  }

  // ── Hapus kolam ────────────────────────────────────
  Future<void> deleteKolam(String id) async {
    await _db.from('kolam').delete().eq('id', id);
  }
}