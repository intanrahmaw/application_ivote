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
    String? password, // Opsional jika ingin ubah password
  }) async {
    final updateData = {
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'no_hp': noHp,
    };

    // Jika password diisi, tambahkan ke data update
    if (password != null && password.isNotEmpty) {
      updateData['password'] = password; // ⚠️ Tetap sebaiknya di-hash
    }

    await supabase.from('users').update(updateData).eq('user_id', userId);
  }
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


