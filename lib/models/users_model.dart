class Users {
  final String userId;
  final String username;
  final String password; 
  final String nama;
  final String email;
  final String alamat;
  final String noHp;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.userId,
    required this.username,
    required this.password,
    required this.nama,
    required this.email,
    required this.alamat,
    required this.noHp,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['user_id'],
      username: json['username'],
      password: json['password'],
      nama: json['nama'],
      email: json['email'],
      alamat: json['alamat'] ?? '',
      noHp: json['no_hp'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
        createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(), // fallback
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'password': password,
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'no_hp': noHp,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
