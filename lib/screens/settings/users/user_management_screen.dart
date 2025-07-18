import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/users_model.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/screens/settings/users/user_list_table.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
import '../../../services/supabase_service.dart';
import '../../settings/users/user_form_screen.dart';
import 'package:application_ivote/screens/profile/profile_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Users> _userList = [];
  bool _isLoading = true;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getUsers();
      setState(() {
        _userList = data.map((e) => Users.fromJson(e)).toList();
      });
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat user: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _supabaseService.deleteUser(userId);
      Get.snackbar('Sukses', 'User dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
      _fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus user: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showDeleteDialog(String userId) {
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
                  // Tombol Hapus (Merah)
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // tutup dialog
                      _deleteUser(userId); // eksekusi penghapusan
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
                  // Tombol Batal (Ungu)
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

  void _navigateAndRefresh({Users? user}) async {
    final result = await Get.to(() => UserFormScreen(user: user));
    if (result == true) _fetchUsers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 🔥 Hilangkan tombol back
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Manajemen User',
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
                child: _userList.isEmpty
                    ? const Center(child: Text('Belum ada data user.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(8),
                                child: UserListTable(
                                  users: _userList,
                                  onEdit: (user) => _navigateAndRefresh(user: user),
                                  onDelete: (userId) => _showDeleteDialog(userId),
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
