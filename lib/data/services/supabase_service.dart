import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // ── Singleton ──────────────────────────────────────
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  // ── Client ─────────────────────────────────────────
  SupabaseClient get client => Supabase.instance.client;

  // ── Auth shortcut ──────────────────────────────────
  GoTrueClient get auth => client.auth;

  // ── User saat ini ──────────────────────────────────
  User? get currentUser => auth.currentUser;

  // ── Cek sudah login ───────────────────────────────
  bool get isLoggedIn => currentUser != null;

  // ── Init — dipanggil di main.dart ─────────────────
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url:     url,
      anonKey: anonKey,
    );
  }
}

// ── Shortcut global ───────────────────────────────────
final supabase = SupabaseService.instance.client;