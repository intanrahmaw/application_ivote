class Admin {
  final String adminId;
  final String username;
  final String password;
  final String nama;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.adminId,
    required this.username,
    required this.password,
    required this.nama,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      adminId: json['admin_id'],
      username: json['username'],
      password: json['password'],
      nama: json['nama'],
      avatarUrl: json['avatar_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'username': username,
      'password': password,
      'nama': nama,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}