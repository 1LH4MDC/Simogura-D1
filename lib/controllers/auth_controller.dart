import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────
//  AUTH CONTROLLER
//  Dulu bernama AkunController — sudah direname & dipindah
// ─────────────────────────────────────────────────────────────
class AuthController {
  final _repo = AuthRepository();

  // ── Login → panggil repository ─────────────────────
  Future<UserModel> login(String username, String password) async {
    return await _repo.login(username, password);
  }

  // ── Logout → hapus session ─────────────────────────
  Future<void> logout() async {
    await _repo.logout();
  }

  // ── Fetch profil berdasarkan id ────────────────────
  Future<UserModel?> fetchProfile(int id) async {
    return await _repo.fetchProfile(id);
  }

  // ── Update profil (nama, username) ────────────────
  Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    await _repo.updateProfile(id, data);
  }

  // ── Ubah password (admin only) ─────────────────────
  Future<void> ubahPassword(int id, String passwordBaru) async {
    await _repo.updateProfile(id, {'password': passwordBaru});
  }

  // ── Cek apakah ada session tersimpan ───────────────
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return null;
    return await _repo.fetchProfile(userId);
  }
}