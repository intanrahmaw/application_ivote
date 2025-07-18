import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/auth/login_screen.dart';
import 'package:application_ivote/screens/profile/edit_account_screen.dart';
import 'package:application_ivote/utils/global_user.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    print('🧾 Username login: $loggedInUserName');
    print('🧾 Role login: $loggedInUserRole');

    if (loggedInUserName.isEmpty || loggedInUserRole.isEmpty) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    try {
      final table = (loggedInUserRole.toLowerCase() == 'admin') ? 'admin' : 'users';
      print('🔍 Mencari username: $loggedInUserName di tabel: $table');

      final data = await supabase
          .from(table)
          .select()
          .ilike('username', loggedInUserName.trim())
          .maybeSingle();

      print('📦 Data supabase: $data');

      if (!mounted) return;

      if (data == null) {
        setState(() {
          displayName = 'Data tidak ditemukan';
          avatarUrl = null;
          isLoading = false;
        });
      } else {
        setState(() {
          displayName = data['username'] ?? 'Pengguna';
          avatarUrl = data['avatar_url'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Gagal ambil data profil: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                          ? NetworkImage(avatarUrl!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 45, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      displayName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    ListTile(
                      onTap: () async {
                        await Get.to(() => const EditAccountScreen());
                        _loadUserProfile(); // Refresh profil setelah diedit
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        child: const Icon(Icons.edit, color: Colors.black),
                      ),
                      title: const Text('Edit Profil'),
                    ),
                    ListTile(
                      onTap: _logout,
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        child: const Icon(Icons.logout, color: Colors.black),
                      ),
                      title: const Text('Logout'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
