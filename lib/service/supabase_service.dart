import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // 🔹 Upload image dari File (Android/iOS/Desktop)
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

  // 🔹 Upload image dari bytes (Web)
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

  // 🔹 Tambah kandidat baru
  Future<void> addCandidate({
    required String electionId,
    required String nama,
    required String visi,
    required String misi,
    required String? fotoUrl,
  }) async {
    final response = await supabase.from('candidates').insert({
      'election_id': electionId,
      'nama': nama,
      'visi': visi,
      'misi': misi,
      'foto': fotoUrl,
    });

    if (response != null && response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  // 🔹 Update kandidat
  Future<void> updateCandidate({
    required String candidateId,
    required String electionId,
    required String nama,
    required String visi,
    required String misi,
    required String? fotoUrl,
  }) async {
    final response = await supabase
        .from('candidates')
        .update({
          'election_id': electionId,
          'nama': nama,
          'visi': visi,
          'misi': misi,
          'foto': fotoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('candidate_id', candidateId);

    if (response != null && response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  // 🔹 Ambil semua kandidat
  Future<List<Map<String, dynamic>>> fetchCandidates() async {
    final response = await supabase.from('candidates').select('*');
    return List<Map<String, dynamic>>.from(response);
  }

  // 🔹 Hapus kandidat
  Future<void> deleteCandidate(String candidateId) async {
    final response =
        await supabase.from('candidates').delete().eq('candidate_id', candidateId);

    if (response != null && response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
