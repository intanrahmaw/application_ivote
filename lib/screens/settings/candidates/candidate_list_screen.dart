import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/candidates_model.dart';
import 'package:application_ivote/services/candidate_supbase_service.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'candidate_form_screen.dart';

class CandidatListScreen extends StatefulWidget {
  const CandidatListScreen({super.key});

  @override
  State<CandidatListScreen> createState() => _CandidatListScreenState();
}

class _CandidatListScreenState extends State<CandidatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Candidate> _kandidatList = [];
  bool _isLoading = true;

  // 1. Variabel untuk indeks navbar
  final int _selectedIndex = 1;

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
      Get.snackbar(
        'Error',
        'Gagal memuat kandidat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateAndRefresh({Candidate? kandidat}) async {
    final result = await Get.to(() => CandidateFormScreen(candidate: kandidat));
    if (result == true) _fetchKandidatList();
  }

  void _showDeleteDialog(String candidateId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red.shade600,
          size: 50,
        ),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus kandidat ini?'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteKandidat(candidateId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteKandidat(String candidateId) async {
    try {
      await _supabaseService.deleteCandidate(candidateId);
      Get.snackbar(
        'Sukses',
        'Kandidat berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _fetchKandidatList();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus kandidat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 2. Fungsi untuk menangani tap pada navbar
  void _onItemTapped(int index) {
    if (index == _selectedIndex && index != 1) return;

    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          DashboardAdminMenu.show(context);
          break;
        case 2:
          Get.offAllNamed('/result');
          break;
        case 3:
          Get.offAllNamed('/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          Get.offAllNamed('/vote');
          break;
        case 2:
          Get.offAllNamed('/result');
          break;
        case 3:
          Get.offAllNamed('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manajemen Kandidat",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        // Tombol kembali otomatis ditangani oleh GetX saat navigasi
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () => _navigateAndRefresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tambah'),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDataTable(),
      // 3. Menambahkan bottomNavigationBar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDataTable() {
    if (_kandidatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Kandidat",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text(
              "Tekan tombol 'Tambah' untuk menambahkan kandidat baru.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: PaginatedDataTable(
            source: _CandidateDataSource(
              kandidatList: _kandidatList,
              onEdit: (kandidat) => _navigateAndRefresh(kandidat: kandidat),
              onDelete: (id) => _showDeleteDialog(id),
            ),
            header: const Text(
              'Daftar Kandidat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'No',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Prodi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Foto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Aksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            columnSpacing: 30,
            horizontalMargin: 20,
            rowsPerPage: 10,
            showCheckboxColumn: false,
          ),
        );
      },
    );
  }
}

// Class Data Source untuk PaginatedDataTable
class _CandidateDataSource extends DataTableSource {
  final List<Candidate> kandidatList;
  final Function(Candidate) onEdit;
  final Function(String) onDelete;

  _CandidateDataSource({
    required this.kandidatList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= kandidatList.length) return null;
    final kandidat = kandidatList[index];
    final imageUrl = kandidat.imageUrl;

    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(kandidat.nama)),
        DataCell(
          Text(kandidat.organisasi),
        ), // Menggunakan 'organisasi' sebagai 'Prodi'
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child:
                (imageUrl != null && imageUrl.isNotEmpty)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                      ),
                    )
                    : const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => onEdit(kandidat),
                tooltip: 'Ubah Data',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(kandidat.candidateId),
                tooltip: 'Hapus Data',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => kandidatList.length;
  @override
  int get selectedRowCount => 0;
}
