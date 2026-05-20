// ═══════════════════════════════════════════════════════
//  user_model.dart
// ═══════════════════════════════════════════════════════
class UserModel {
  final int      id;
  final String   username;
  final String   password;
  final String   role;       // 'admin' | 'user'
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  // ── Helper cek role ──────────────────────────────────
  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id:          map['id']           ?? 0,
        username:    map['username']     ?? '',
        password:    map['password']     ?? '',
        role:        map['role']         ?? 'user',
        createdAt:   map['created_at']   != null
            ? DateTime.parse(map['created_at'])
            : null,
        lastLoginAt: map['lastlogin_at'] != null
            ? DateTime.parse(map['lastlogin_at'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'username':     username,
        'password':     password,
        'role':         role,
        'created_at':   createdAt?.toIso8601String(),
        'lastlogin_at': lastLoginAt?.toIso8601String(),
      };
}