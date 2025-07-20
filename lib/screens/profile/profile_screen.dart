import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/auth/login_screen.dart';
import 'package:application_ivote/screens/profile/edit_account_screen.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart'; // ← Tambahkan ini

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  String displayName = 'Loading...';
  String? avatarUrl;
  bool isLoading = true;
  int _selectedIndex = 3; // ← Profil tab index

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (loggedInUserName.isEmpty || loggedInUserRole.isEmpty) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    try {
      final table = (loggedInUserRole.toLowerCase() == 'admin') ? 'admin' : 'users';
      final field = (loggedInUserRole.toLowerCase() == 'admin') ? 'username' : 'username';

      final data = await supabase
          .from(table)
          .select()
          .eq(field, loggedInUserName.trim())
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        displayName = data?['nama'] ?? 'Pengguna';
        avatarUrl = data?['avatar_url'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        displayName = 'Gagal Ambil Nama';
        avatarUrl = null;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    loggedInUserName = '';
    loggedInUserRole = '';
    Get.offAll(() => const LoginScreen());
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

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
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                          ? NetworkImage(avatarUrl!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildProfileOption(
                      icon: Icons.edit,
                      text: 'Edit Profil',
                      onTap: () async {
                        await Get.to(() => const EditAccountScreen());
                        _loadUserProfile();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildProfileOption(
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: _logout,
                      isDanger: true,
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDanger ? Colors.red[50] : Colors.deepPurple[50],
              child: Icon(
                icon,
                color: isDanger ? Colors.red : Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDanger ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
