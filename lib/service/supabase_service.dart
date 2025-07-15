import 'dart:typed_data';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // ==========================
  // CANDIDATE SERVICE
  // ==========================

  // Ambil semua kandidat
  Future<List<Map<String, dynamic>>> getCandidates() async {
    final response = await supabase.from('candidates').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Hapus kandidat berdasarkan ID
  Future<void> deleteCandidate(String candidateId) async {
    await supabase.from('candidates').delete().eq('candidate_id', candidateId);
  }

  // Tambah kandidat baru
  Future<void> addCandidate({
    required String electionId,
    required String nama,
    required String visi,
    required String misi,
    String? fotoUrl,
  }) async {
    await supabase.from('candidates').insert({
      'election_id': electionId,
      'nama': nama,
      'visi': visi,
      'misi': misi,
      'foto': fotoUrl,
    });
  }

  // Update kandidat berdasarkan ID
  Future<void> updateCandidate({
    required String candidateId,
    required String electionId,
    required String nama,
    required String visi,
    required String misi,
    String? fotoUrl,
  }) async {
    final updates = {
      'election_id': electionId,
      'nama': nama,
      'visi': visi,
      'misi': misi,
      'foto': fotoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await supabase
        .from('candidates')
        .update(updates)
        .eq('candidate_id', candidateId)
        .select();

    if (response.isEmpty) {
      throw Exception('Gagal update: kandidat tidak ditemukan atau tidak berubah.');
    }
  }

  // Upload gambar dari File (Android/iOS/Desktop)
  Future<String> uploadImage(File file, String bucket, String path) async {
    final fileBytes = await file.readAsBytes();
    final response = await supabase.storage.from(bucket).uploadBinary(
      path,
      fileBytes,
      fileOptions: const FileOptions(upsert: true),
    );

    if (response.isEmpty) {
      throw Exception("Gagal mengupload gambar");
    }

    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  // Upload gambar dari bytes (Web)
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String bucketName,
    String fileName,
  ) async {
    final response = await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    if (response.isEmpty) {
      throw Exception("Gagal mengupload gambar");
    }

    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }
}
