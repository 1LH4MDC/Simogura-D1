class Validators {
  // ── Email ─────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  // ── Password ──────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  // ── Konfirmasi Password ───────────────────────────
  static String? konfirmasiPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (value != original) return 'Konfirmasi password tidak sesuai';
    return null;
  }

  // ── Required (wajib diisi) ────────────────────────
  static String? required(String? value, {String label = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$label tidak boleh kosong';
    return null;
  }

  // ── Angka positif ─────────────────────────────────
  static String? positiveNumber(String? value, {String label = 'Nilai'}) {
    if (value == null || value.trim().isEmpty) return '$label tidak boleh kosong';
    final n = num.tryParse(value.trim());
    if (n == null) return '$label harus berupa angka';
    if (n <= 0) return '$label harus lebih dari 0';
    return null;
  }
}