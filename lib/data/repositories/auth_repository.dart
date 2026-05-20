import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── Login ──────────────────────────────────────────
  Future<UserModel> login(String username, String password) async {
    final hash = _hashPassword(password);

    final response = await _supabase
        .from('akun')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (response == null) throw 'Username tidak ditemukan.';
    if (response['password'] != hash) throw 'Password salah.';

    // Update lastlogin_at
    await _supabase
        .from('akun')
        .update({'lastlogin_at': DateTime.now().toIso8601String()})
        .eq('id', response['id']);

    final user = UserModel.fromMap(response);

    // ── Simpan session ke SharedPreferences ──────────
    await _saveSession(user.id);

    return user;
  }

  // ── Fetch profil berdasarkan id ────────────────────
  Future<UserModel?> fetchProfile(int id) async {
    final response = await _supabase
        .from('akun')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  // ── Update profil ──────────────────────────────────
  Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    if (data.containsKey('password') && data['password'] != null) {
      data['password'] = _hashPassword(data['password']);
    }
    await _supabase.from('akun').update(data).eq('id', id);
  }

  // ── Simpan id user ke SharedPreferences ───────────
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  // ── Hapus session (logout) ─────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}