import 'package:application_ivote/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class SupabaseService {
  // ==========================
  // ELECTION SERVICE
  // ==========================

  Future<List<Map<String, dynamic>>> getElections() async {
    final response = await supabase.from('election').select();
    return response;
  }

  Future<void> deleteElection(String electionId) async {
    await supabase.from('election').delete().eq('id', electionId);
  }

  Future<void> addElection({
    required String nama,
    required String deskripsi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    await supabase.from('election').insert({
      'nama': nama,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
    });
  }

  Future<void> updateElection({
    required String electionId,
    required String nama,
    required String deskripsi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    await supabase.from('election').update({
      'nama': nama,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
    }).eq('id', electionId);
  }
}
