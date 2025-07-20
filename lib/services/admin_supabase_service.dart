// lib/services/supabase_admin_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_model.dart';

final supabase = Supabase.instance.client;

/// ==========================
/// ADMIN SERVICE
/// ==========================

/// Ambil data admin berdasarkan username
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
Future<void> updateAdmin({
  required String adminId,
  required String username,
  required String password,
  required String nama,
}) async {
  final updates = {
    'username': username,
    'password': password,
    'nama': nama,
    'updated_at': DateTime.now().toIso8601String(),
  };

  final response = await supabase
      .from('admin')
      .update(updates)
      .eq('admin_id', adminId)
      .select();

  if (response.isEmpty) {
    throw Exception('Gagal update: admin tidak ditemukan.');
  }
}
