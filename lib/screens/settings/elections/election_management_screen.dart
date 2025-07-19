import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/utils/app_routes.dart';
import 'package:application_ivote/models/elections_model.dart';
import 'package:application_ivote/screens/settings/elections/election_form_screen.dart';
import 'package:application_ivote/screens/settings/elections/election_list_table.dart';
import 'package:application_ivote/services/election_supabase_service.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
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
      List<Elections> elections = data.map((e) => Elections.fromJson(e)).toList();

      DateTime now = DateTime.now();
      for (var election in elections) {
        if (election.isActive && election.endTime.isBefore(now)) {
          await _supabaseService.updateElectionStatus(election.electionId, false);
        }
      }

      final updatedData = await _supabaseService.getElections();
      setState(() {
        _electionList = updatedData.map((e) => Elections.fromJson(e)).toList();
      });
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat election: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
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
          return;
        case 1:
          SubMenuAdmin.show(context);
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
          'Manajemen Election',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                bool hasActiveElection = _electionList.any((e) => e.isActive);
                if (hasActiveElection) {
                  Get.snackbar(
                    'Tidak Bisa Menambah',
                    'Masih ada election yang sedang berlangsung.',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                } else {
                  _navigateAndRefresh();
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                child: _electionList.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Belum ada data election.',
                            style: TextStyle(color: Colors.grey),
                          ),
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
                                child: ElectionListTable(
                                  elections: _electionList,
                                  onEdit: (election) => _navigateAndRefresh(election: election),
                                  // onDelete dihapus
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
