import 'package:supabase_flutter/supabase_flutter.dart';

// Inisialisasi Supabase client
final supabase = Supabase.instance.client;

class SupabaseService {
  // ==========================
  // USER SERVICE
  // ==========================

  // Ambil semua user
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await supabase.from('users').select();
    return response;
  }

  // Hapus user
  Future<void> deleteUser(String userId) async {
    await supabase.from('users').delete().eq('user_id', userId);
  }

  // Tambah user baru
  Future<void> addUser({
    required String username,
    required String password,
    required String nama,
    required String email,
    required String alamat,
    required String noHp,
  }) async {
    await supabase.from('users').insert({
      'username': username,
      'password': password, // ⚠️ Password sebaiknya di-hash
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'no_hp': noHp,
    });
  }

  // Update user (opsional ubah password)
 Future<void> updateUser({
  required String userId,
  required String nama,
  required String email,
  required String alamat,
  required String noHp,
  String? password,
  String? avatarUrl,
}) async {
  final updates = {
    'nama': nama,
    'email': email,
    'alamat': alamat,
    'no_hp': noHp,
    'updated_at': DateTime.now().toIso8601String(),
  };

  if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
  if (password != null && password.isNotEmpty) updates['password'] = password;

  await Supabase.instance.client
      .from('users')
      .update(updates)
      .eq('user_id', userId);
}



// ==========================
// VOTING SERVICE
// ==========================

// Tambahkan vote
Future<void> addVote({
  required String userId,
  required String candidateId,
}) async {
  // Cek apakah user sudah pernah vote
  final existingVote = await supabase
      .from('votes')
      .select()
      .eq('user_id', userId)
      .maybeSingle(); // Ambil satu data, atau null jika belum ada

  if (existingVote != null) {
    throw Exception("Anda sudah melakukan vote.");
  }

  await supabase.from('votes').insert({
    'user_id': userId,
    'candidate_id': candidateId,
  });
}

// Ambil total suara per kand


}