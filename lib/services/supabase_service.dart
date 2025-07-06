import 'package:supabase_flutter/supabase_flutter.dart';

// Inisialisasi Supabase client (gunakan di mana pun)
final supabase = Supabase.instance.client;

class SupabaseService {
  // ==========================
  // USER SERVICE
  // ==========================

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await supabase.from('users').select();
    return response;
  }

  Future<void> deleteUser(String userId) async {
    await supabase.from('users').delete().eq('user_id', userId);
  }

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
      'password': password, // ⚠️ Hati-hati: sebaiknya hash password
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'no_hp': noHp,
    });
  }

  Future<void> updateUser({
    required String userId,
    required String nama,
    required String email,
    required String alamat,
    required String noHp,
  }) async {
    await supabase.from('users').update({
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'no_hp': noHp,
    }).eq('user_id', userId);
  }
}