import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/usermodels.dart';
import 'package:application_ivote/widgets/user_list_table.dart';// pastikan import ini sesuai
import '../../services/supabase_service.dart';
import '../home/user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<AppUser> _userList = [];
  bool _isLoading = true;

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
       _userList = data.map((e) => AppUser.fromJson(e)).toList(); // ✅ AMAN

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
    Get.defaultDialog(
      title: 'Hapus User',
      middleText: 'Yakin ingin menghapus user ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _deleteUser(userId);
      },
    );
  }

  void _navigateAndRefresh({AppUser? user}) async {
  final result = await Get.to(() => UserFormScreen(user: user));
  if (result == true) _fetchUsers();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Manajemen User', style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: _userList.isEmpty
                    ? const Center(child: Text('Belum ada data user.'))
                    : UserListTable(
                        users: _userList,
                        onEdit: (user) => _navigateAndRefresh(user: user),
                        onDelete: (userId) => _showDeleteDialog(userId),
                      ),
              ),
            ),
    );
  }
}
