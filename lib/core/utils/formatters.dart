import 'package:intl/intl.dart';

class Formatters {
  // ── Tanggal: 10/12/2026 ───────────────────────────
  static String tanggal(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);

  // ── Tanggal panjang: 04 Mei 2026 ─────────────────
  static String tanggalPanjang(DateTime dt) =>
      DateFormat('dd MMMM yyyy', 'id_ID').format(dt);

  // ── Jam: 06.00 ────────────────────────────────────
  static String jam(DateTime dt) => DateFormat('HH.mm').format(dt);

  // ── Jam + tanggal: 04 Mei 2026, 08.30 WIB ────────
  static String jamTanggal(DateTime dt) =>
      '${tanggalPanjang(dt)}, ${DateFormat('HH.mm').format(dt)} WIB';

  // ── Angka: 1.000 ──────────────────────────────────
  static String angka(num value) =>
      NumberFormat('#,###', 'id_ID').format(value);

  // ── Desimal: 29.5 → "29.5" ───────────────────────
  static String desimal(double value, {int desimalDigit = 1}) =>
      value.toStringAsFixed(desimalDigit);

  // ── Gram: 2000 → "2.000 gram" ────────────────────
  static String gram(num value) => '${angka(value)} gram';

  // ── Kg: 1.5 → "1.5 kg" ───────────────────────────
  static String kg(double value) => '${desimal(value)} kg';
}