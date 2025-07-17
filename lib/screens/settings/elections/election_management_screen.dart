import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/utils/app_routes.dart';
import 'package:application_ivote/screens/home/dashboard_screen.dart';
import 'package:application_ivote/models/elections_model.dart';
import 'package:application_ivote/screens/settings/elections/election_form_screen.dart';
import 'package:application_ivote/screens/settings/elections/election_list_table.dart';
import 'package:application_ivote/services/election_supabase_service.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_admin.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:application_ivote/utils/global_user.dart';

class ElectionManagementScreen extends StatefulWidget {
  const ElectionManagementScreen({super.key});

  @override
  State<ElectionManagementScreen> createState() => _ElectionManagementScreenState();
}

class _ElectionManagementScreenState extends State<ElectionManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Elections> _electionList = [];
  bool _isLoading = true;

  int _selectedIndex = 1;

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
        _electionList = data.map((e) => Elections.fromJson(e)).toList();
      });
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat election: \$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteElection(String electionId) async {
    try {
      await _supabaseService.deleteElection(electionId);
      Get.snackbar('Sukses', 'Election dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      _fetchelections();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus election: \$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showDeleteDialog(String electionId) {
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
                'Apakah anda yakin\nmenghapus data ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _deleteElection(electionId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Hapus'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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

  void _navigateAndRefresh({Elections? election}) async {
    final result = await Get.to(() => ElectionFormScreen(election: election));
    if (result == true) _fetchelections();
  }

  void _onItemTapped(int index) {
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          DashboardAdminMenu.show(context); // tidak perlu return
          break;
        case 2:
          Get.offNamed('/admin/hasil-vote');
          break;
        case 3:
          Get.offNamed('/admin/profil');
          break;
      }
    }

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
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
        title: const Text(
          'Manajemen Election',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () => _navigateAndRefresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(8),
                                child: ElectionListTable(
                                  elections: _electionList,
                                  onEdit: (election) => _navigateAndRefresh(election: election),
                                  onDelete: (electionId) => _showDeleteDialog(electionId),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBarAdmin(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
