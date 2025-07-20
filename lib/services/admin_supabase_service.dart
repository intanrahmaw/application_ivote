// lib/services/supabase_admin_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_model.dart'; // pastikan path sesuai dengan file kamu

final supabase = Supabase.instance.client;

/// ==========================
/// ADMIN SERVICE
/// ==========================

class AdminSupabaseService {
  
Future<Admin?> getAdminByUsername(String username) async {
  final response = await supabase
      .from('admin') // pastikan nama tabel sudah benar di Supabase
      .select()
      .eq('username', username)
      .maybeSingle();

  if (response == null) return null;
  return Admin.fromJson(response);
}

/// Update data admin berdasarkan admin_id
/// Update data admin berdasarkan admin_id
Future<void> updateAdmin({
  required String adminId,
  required String username,
  required String nama,
  String? password,
  String? avatarUrl,
}) async {
  final updates = {
    'username': username,
    'nama': nama,
    'updated_at': DateTime.now().toIso8601String(),
  };

  if (password != null && password.isNotEmpty) {
    updates['password'] = password;
  }

  if (avatarUrl != null) {
    updates['avatar_url'] = avatarUrl;
  }

  final response = await supabase
      .from('admin')
      .update(updates)
      .eq('admin_id', adminId)
      .select()
      .maybeSingle(); // ✅ INI YANG BENAR

  if (response == null) {
    throw Exception('Admin dengan ID $adminId tidak ditemukan atau gagal diupdate.');
  }
}

}
