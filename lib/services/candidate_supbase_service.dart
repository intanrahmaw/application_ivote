import 'dart:typed_data';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // ==========================
  // CANDIDATE SERVICE
  // ==========================

  /// Ambil semua kandidat dari election yang masih aktif dan belum berakhir
  Future<List<Map<String, dynamic>>> getCandidates() async {
    final now = DateTime.now().toIso8601String();

    final response = await supabase
        .from('candidates')
        .select('*, elections!inner(*)') // Join dengan tabel elections
        .eq('elections.is_active', true)
        .gte('elections.end_time', now); // Hanya election yang belum berakhir

    return List<Map<String, dynamic>>.from(response);
  }

  /// Hapus semua vote berdasarkan ID kandidat
  Future<void> deleteVotesByCandidate(String candidateId) async {
    await supabase
        .from('votes')
        .delete()
        .eq('candidate_id', candidateId);
  }

  /// Hapus kandidat beserta semua vote-nya
  Future<void> deleteCandidate(String candidateId) async {
    await deleteVotesByCandidate(candidateId); // Hapus votes dulu
    await supabase
        .from('candidates')
        .delete()
        .eq('candidate_id', candidateId); // Lalu hapus kandidat
  }

  /// Tambah kandidat baru
  Future<void> addCandidate({
    required String electionId,
    required String nama,
    required String organisasi,
    required String label,
    required String visi,
    required String misi,
    String? imageUrl,
  }) async {
    await supabase.from('candidates').insert({
      'elections_id': electionId,
      'nama': nama,
      'organisasi': organisasi,
      'label': label,
      'visi': visi,
      'misi': misi,
      'image_url': imageUrl,
    });
  }

  /// Update data kandidat
  Future<void> updateCandidate({
    required String candidateId,
    required String electionId,
    required String nama,
    required String organisasi,
    required String label,
    required String visi,
    required String misi,
    String? imageUrl,
  }) async {
    final updates = {
      'elections_id': electionId,
      'nama': nama,
      'organisasi': organisasi,
      'label': label,
      'visi': visi,
      'misi': misi,
      'image_url': imageUrl,
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

  /// Upload gambar dari File (Android/iOS/Desktop)
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

  /// Upload gambar dari bytes (Web)
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
