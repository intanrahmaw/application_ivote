import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/candidates_model.dart';
import 'package:application_ivote/services/candidate_supbase_service.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'candidate_form_screen.dart';
import 'package:application_ivote/screens/profile/profile_screen.dart';

class CandidatListScreen extends StatefulWidget {
  const CandidatListScreen({super.key});

  @override
  State<CandidatListScreen> createState() => _CandidatListScreenState();
}

class _CandidatListScreenState extends State<CandidatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Candidate> _kandidatList = [];
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchKandidatList();
  }

  Future<void> _fetchKandidatList() async {
    setState(() => _isLoading = true);
    try {
      final result = await _supabaseService.getCandidates();
      setState(() {
        _kandidatList = result.map((item) => Candidate.fromMap(item)).toList();
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kandidat: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateAndRefresh({Candidate? kandidat}) async {
    final result = await Get.to(() => CandidateFormScreen(candidate: kandidat));
    if (result == true) _fetchKandidatList();
  }

  void _showDeleteDialog(String candidateId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Apakah anda yakin\nmenghapus kandidat ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _deleteKandidat(candidateId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Hapus'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteKandidat(String candidateId) async {
    try {
      await _supabaseService.deleteCandidate(candidateId);
      Get.snackbar('Sukses', 'Kandidat dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      _fetchKandidatList();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus kandidat: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _onItemTapped(int index) {
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          return;
        case 1:
          DashboardAdminMenu.show(context); // submenu setting
          return;
        case 2:
          Get.offAllNamed('/result');
          return;
        case 3:
          Get.offAllNamed('/profile');
          return;
      }
    } else {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          return;
        case 1:
          Get.offAllNamed('/vote');
          return;
        case 2:
          Get.offAllNamed('/result');
          return;
        case 3:
          Get.offAllNamed('/profile');
          return;
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Organisasi', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Label', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Visi', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Misi', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Center(child: Text('Foto', style: TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(flex: 3, child: Center(child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildDataRow(Candidate kandidat, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text((index + 1).toString())),
          Expanded(flex: 3, child: Text(kandidat.nama)),
          Expanded(flex: 3, child: Text(kandidat.organisasi)),
          Expanded(flex: 3, child: Text(kandidat.label)),
          Expanded(flex: 3, child: Text(kandidat.visi, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(kandidat.misi, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Center(
              child: (kandidat.imageUrl != null && kandidat.imageUrl!.isNotEmpty)
                  ? Image.network(kandidat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _navigateAndRefresh(kandidat: kandidat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(kandidat.candidateId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Manajemen Kandidat', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () => _navigateAndRefresh(),
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
                child: _kandidatList.isEmpty
                    ? const Center(child: Text('Belum ada data kandidat.'))
                    : ListView.builder(
                        itemCount: _kandidatList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildHeader();
                          return _buildDataRow(_kandidatList[index - 1], index - 1);
                        },
                      ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}