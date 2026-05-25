import '../data/models/kolam_model.dart';
import '../data/repositories/kolam_repository.dart';

// ─────────────────────────────────────────────────────────────
//  KOLAM CONTROLLER
// ─────────────────────────────────────────────────────────────
class KolamController {
  final _repo = KolamRepository();

  // ── Fetch semua kolam ──────────────────────────────────────
  Future<List<KolamModel>> getKolams() async { // ✅ Hapus parameter userId
    return await _repo.getKolams(); // ✅ Hapus argumen userId
  }

  // ── Fetch satu kolam ───────────────────────────────
  Future<KolamModel?> getKolamById(String id) async {
    return await _repo.getKolamById(id);
  }

  // ── Tambah kolam baru 
  Future<KolamModel> createKolam({
    required String nama,
    required String alamat,
    required int totalIkan,
    required DateTime tanggalMulai,
    required double targetBobot,
    required int durasiTarget,
    required int userId,
  }) async {
    return await _repo.createKolam(
      nama:          nama,
      alamat:        alamat,
      totalIkan:     totalIkan,
      tanggalMulai:  tanggalMulai,
      targetBobot:   targetBobot,
      durasiTarget:  durasiTarget,
      userId:        userId,
    );
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
    await _repo.updateKolam(
      id:            id,
      nama:          nama,
      alamat:        alamat,
      totalIkan:     totalIkan,
      targetBobot:   targetBobot,
      durasiTarget:  durasiTarget,
    );
  }

  // ── Selesaikan kolam ───────────────────────────────
  Future<void> selesaikanKolam(String id) async {
    await _repo.selesaikanKolam(id);
  }

  // ── Hapus kolam ────────────────────────────────────
  Future<void> deleteKolam(String id) async {
    await _repo.deleteKolam(id);
  }
}