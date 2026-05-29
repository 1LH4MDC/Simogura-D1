import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

// ─────────────────────────────────────────────────────────────
//  WARNA
// ─────────────────────────────────────────────────────────────
class _C {
  static const navy    = Color(0xFF0C344D);
  static const blue    = Color(0xFF2FA8D5);
  static const white   = Color(0xFFFFFFFF);
  static const bg      = Color(0xFFF4F6F8);
  static const text    = Color(0xFF1A2E44);
  static const subtext = Color(0xFF7A9BB0);
  static const line    = Color(0xFFE8EEF3);
  static const green   = Color(0xFF4CAF50);
  static const warning = Color(0xFFF4A623);
  static const danger  = Color(0xFFE53935);
  static const purple  = Color(0xFF9C27B0);
}

// ─────────────────────────────────────────────────────────────
//  MODEL NOTIFIKASI DUMMY
// ─────────────────────────────────────────────────────────────
class _Notif {
  final String   id;
  final String   namaKolam;
  final String   tipe;      // 'suhu' | 'ph' | 'amonia' | 'ketinggian'
  final String   pesan;
  final String   detail;
  final DateTime waktu;
  bool           isRead;

  _Notif({
    required this.id,
    required this.namaKolam,
    required this.tipe,
    required this.pesan,
    required this.detail,
    required this.waktu,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────────────────────
//  USER NOTIFIKASI SCREEN
// ─────────────────────────────────────────────────────────────
class UserNotifikasiScreen extends StatefulWidget {
  final UserModel user;

  const UserNotifikasiScreen({super.key, required this.user});

  @override
  State<UserNotifikasiScreen> createState() => _UserNotifikasiScreenState();
}

class _UserNotifikasiScreenState extends State<UserNotifikasiScreen> {

  // ── Filter tab: semua / belum dibaca ──────────────
  int _filterIndex = 0; // 0 = Semua, 1 = Belum Dibaca

  // ⚠️ DATA DUMMY — ganti dengan stream NotifikasiRepository nanti
  final List<_Notif> _notifList = [
    _Notif(
      id: '1',
      namaKolam: 'Kolam Pertama',
      tipe: 'suhu',
      pesan: 'Suhu air melebihi batas normal!',
      detail: 'Suhu terdeteksi 34.2°C, melebihi batas aman 30°C.',
      waktu: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    _Notif(
      id: '2',
      namaKolam: 'Kolam Kedua',
      tipe: 'ph',
      pesan: 'pH air tidak normal!',
      detail: 'Nilai pH terdeteksi 5.2, di bawah batas aman 6.5.',
      waktu: DateTime.now().subtract(const Duration(minutes: 22)),
      isRead: false,
    ),
    _Notif(
      id: '3',
      namaKolam: 'Kolam Pertama',
      tipe: 'amonia',
      pesan: 'Kadar amonia melebihi batas aman!',
      detail: 'Amonia terdeteksi 28 ppm, melebihi batas aman 25 ppm.',
      waktu: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    _Notif(
      id: '4',
      namaKolam: 'Kolam Ketiga',
      tipe: 'ketinggian',
      pesan: 'Ketinggian air tidak normal!',
      detail: 'Ketinggian air terdeteksi 45 cm, di bawah batas minimum 60 cm.',
      waktu: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    _Notif(
      id: '5',
      namaKolam: 'Kolam Kedua',
      tipe: 'suhu',
      pesan: 'Suhu air kembali normal',
      detail: 'Suhu air sudah kembali ke kisaran normal 28.5°C.',
      waktu: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
  ];

  List<_Notif> get _filtered {
    if (_filterIndex == 1) {
      return _notifList.where((n) => !n.isRead).toList();
    }
    return _notifList;
  }

  int get _unreadCount => _notifList.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final notif = _notifList.firstWhere((n) => n.id == id);
      notif.isRead = true;
    });
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifList) {
        n.isRead = true;
      }
    });
  }

  void _deleteNotif(String id) {
    setState(() {
      _notifList.removeWhere((n) => n.id == id);
    });
  }

  // ── Waktu relatif ─────────────────────────────────
  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  // ── Config per tipe ───────────────────────────────
  Color _tipeColor(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'suhu':      return _C.danger;
      case 'ph':        return _C.purple;
      case 'amonia':    return _C.warning;
      case 'ketinggian':return _C.blue;
      default:          return _C.subtext;
    }
  }

  IconData _tipeIcon(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'suhu':      return Icons.thermostat_outlined;
      case 'ph':        return Icons.science_outlined;
      case 'amonia':    return Icons.waves_outlined;
      case 'ketinggian':return Icons.water_outlined;
      default:          return Icons.notifications_outlined;
    }
  }

  String _tipeLabel(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'suhu':      return 'Suhu';
      case 'ph':        return 'pH';
      case 'amonia':    return 'Amonia';
      case 'ketinggian':return 'Ketinggian';
      default:          return 'Sensor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: _C.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount belum dibaca',
                style: const TextStyle(
                  color: _C.subtext,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _C.navy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Baca Semua',
                    style: TextStyle(
                      color: _C.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Tab ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildFilterTab(0, 'Semua', _notifList.length),
                  _buildFilterTab(1, 'Belum Dibaca', _unreadCount),
                ],
              ),
            ),
          ),
          
          // ── Daftar Notifikasi ────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _buildNotifCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(int index, String label, int count) {
    final active = _filterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? _C.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? _C.white : _C.subtext,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? _C.white.withOpacity(0.2) : _C.line,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: active ? _C.white : _C.text,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifCard(_Notif notif) {
    final color = _tipeColor(notif.tipe);
    final bgCardColor = notif.isRead ? _C.white : color.withOpacity(0.04);
    final borderColor = notif.isRead ? _C.line : color.withOpacity(0.3);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _C.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _deleteNotif(notif.id),
      child: GestureDetector(
        onTap: () => _showDetailDialog(notif),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(notif.isRead ? 0.02 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ikon Tipe ────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_tipeIcon(notif.tipe), color: color, size: 26),
              ),
              const SizedBox(width: 14),

              // ── Konten ───────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Tipe & Hapus
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _tipeLabel(notif.tipe),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${notif.namaKolam}',
                          style: const TextStyle(
                            color: _C.subtext,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        
                        // ✅ TOMBOL HAPUS (Ikon Sampah)
                        GestureDetector(
                          onTap: () => _deleteNotif(notif.id),
                          child: Icon(Icons.delete_outline, size: 20, color: _C.danger.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Pesan Utama
                    Text(
                      notif.pesan,
                      style: TextStyle(
                        color: _C.text,
                        fontSize: 15,
                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Detail Singkat
                    Text(
                      notif.detail,
                      style: const TextStyle(
                        color: _C.subtext,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Waktu & ✅ TOMBOL TANDAI DIBACA
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: _C.subtext),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(notif.waktu),
                          style: const TextStyle(
                            color: _C.subtext,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!notif.isRead) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _markAsRead(notif.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _C.navy.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tandai Dibaca',
                                style: TextStyle(
                                  color: _C.navy,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _C.navy.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: _C.subtext,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: _C.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semua kondisi kolam dalam keadaan baik.',
            style: TextStyle(color: _C.subtext, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Dialog detail notifikasi ──────────────────────
  void _showDetailDialog(_Notif notif) {
    if (!notif.isRead) _markAsRead(notif.id); // Otomatis dibaca saat dibuka detailnya
    final color = _tipeColor(notif.tipe);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _C.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_tipeIcon(notif.tipe), color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tipeLabel(notif.tipe).toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notif.pesan,
              style: const TextStyle(
                color: _C.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              notif.detail,
              style: const TextStyle(
                color: _C.subtext,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.water_rounded, 'Kolam', notif.namaKolam),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: _C.line, height: 1),
                  ),
                  _buildDetailRow(Icons.access_time_filled, 'Waktu', _relativeTime(notif.waktu)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.navy,
                  foregroundColor: _C.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _C.subtext),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: _C.subtext, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: _C.text, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}