import 'package:application_ivote/models/elecction_model.dart';
import 'package:application_ivote/screens/election/election_form.dart';
import 'package:application_ivote/widgets/election_list_tabel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/service/supabase_service.dart';


class ElectionListScreen extends StatefulWidget {
  const ElectionListScreen({super.key});

  @override
  State<ElectionListScreen> createState() => _ElectionListScreenState();
}

class _ElectionListScreenState extends State<ElectionListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Election> _electionList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchelections();
  }

  Future<void> _fetchelections() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getElections();
      setState(() {
       _electionList = data.map((e) => Election.fromJson(e)).toList(); // ✅ AMAN

      });
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat election: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteelection(String electionId) async {
    try {
      await _supabaseService.deleteElection(electionId);
      Get.snackbar('Sukses', 'election dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      _fetchelections();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus election: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showDeleteDialog(String electionId) {
    Get.defaultDialog(
      title: 'Hapus election',
      middleText: 'Yakin ingin menghapus election ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _deleteelection(electionId);
      },
    );
  }

  void _navigateAndRefresh({Election? election}) async {
  final result = await Get.to(() => ElectionFormScreen(election: election));
  if (result == true) _fetchelections();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Manajemen Election', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () async => _navigateAndRefresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Tambah'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _electionList.isEmpty
                    ? const Center(child: Text('Belum ada data election.'))
                    : ElectionListTable(
                        elections: _electionList,
                        onEdit: (election) => _navigateAndRefresh(election: election),
                        onDelete: (electionId) => _showDeleteDialog(electionId),
                      ),
              ),
            ),
    );
  }
}
