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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Yakin ingin menghapus kandidat ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Hapus'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
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
    // Hapus kandidat beserta semua suaranya
    await _supabaseService.deleteCandidate(candidateId);

    Get.snackbar(
      'Berhasil',
      'Kandidat dan seluruh suara terkait berhasil dihapus.',
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


  void _onItemTapped(int index) {
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          SubMenuAdmin.show(context);
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
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Manajemen Kandidat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _navigateAndRefresh(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
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
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada data kandidat.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(8),
                                child: DataTable(
                                  headingRowColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.deepPurple.shade50),
                                  headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.black87),
                                  columnSpacing: 30,
                                  horizontalMargin: 20,
                                  columns: const [
                                    DataColumn(label: Text('No')),
                                    DataColumn(label: Text('Nama')),
                                    DataColumn(label: Text('Organisasi')),
                                    DataColumn(label: Text('Label')),
                                    DataColumn(label: Text('Visi')),
                                    DataColumn(label: Text('Misi')),
                                    DataColumn(label: Text('Foto')),
                                    DataColumn(label: Center(child: Text('Aksi'))),
                                  ],
                                  rows: List<DataRow>.generate(
                                    _kandidatList.length,
                                    (index) {
                                      final kandidat = _kandidatList[index];
                                      final rowColor = index.isEven
                                          ? Colors.grey.withOpacity(0.05)
                                          : Colors.transparent;

                                      return DataRow(
                                        color: MaterialStateProperty.resolveWith((states) => rowColor),
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(kandidat.nama)),
                                          DataCell(Text(kandidat.organisasi)),
                                          DataCell(Text(kandidat.label)),
                                          DataCell(Text(
                                            kandidat.visi,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                          DataCell(Text(
                                            kandidat.misi,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                          DataCell(
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: kandidat.imageUrl != null &&
                                                      kandidat.imageUrl!.isNotEmpty
                                                  ? Image.network(
                                                      kandidat.imageUrl!,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                                    )
                                                  : const Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                                                  tooltip: 'Edit Kandidat',
                                                  onPressed: () => _navigateAndRefresh(kandidat: kandidat),
                                                  splashRadius: 20,
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_forever_rounded,
                                                      color: Colors.red),
                                                  tooltip: 'Hapus Kandidat',
                                                  onPressed: () =>
                                                      _showDeleteDialog(kandidat.candidateId),
                                                  splashRadius: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
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
