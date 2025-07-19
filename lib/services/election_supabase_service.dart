import 'package:application_ivote/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // ==========================
  // ELECTION SERVICE
  // ==========================

  Future<List<Map<String, dynamic>>> getElections() async {
    final response = await supabase.from('elections').select();
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal mengambil data elections.');
    }
  }

  Future<void> addElection({
    required String judul,
    required String deskripsi,
    required DateTime startTime,
    required DateTime endTime,
    bool isActive = true,
  }) async {
    await supabase.from('elections').insert({
      'judul': judul,
      'deskripsi': deskripsi,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
    });
  }

  Future<void> updateElection({
    required String electionId,
    required String judul,
    required String deskripsi,
    required DateTime startTime,
    required DateTime endTime,
    required bool isActive,
  }) async {
    final updates = {
      'judul': judul,
      'deskripsi': deskripsi,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
    };

    final response = await supabase
        .from('elections')
        .update(updates)
        .eq('elections_id', electionId)
        .select();

    if (response.isEmpty) {
      throw Exception('Gagal update: data tidak ditemukan atau tidak berubah.');
    }
  }

  Future<void> updateElectionStatus(String electionId, bool isActive) async {
    final response = await supabase
        .from('elections')
        .update({'is_active': isActive})
        .eq('elections_id', electionId);

    if (response == null) {
      throw Exception('Gagal update status.');
    }
  }
}