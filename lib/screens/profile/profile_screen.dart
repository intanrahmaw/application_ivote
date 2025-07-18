import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/auth/login_screen.dart';
import 'package:application_ivote/screens/profile/edit_profile.dart';
import 'package:application_ivote/utils/global_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  String username = 'Loading...';
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (loggedInUserId.isEmpty) {
      Future.microtask(() => Get.offAll(() => const LoginScreen()));
      return;
    }

    try {
      final data = await supabase
          .from('users')
          .select('nama, avatar_url')
          .eq('user_id', loggedInUserId)
          .single();

      setState(() {
        username = data['nama'] ?? 'Pengguna';
        avatarUrl = data['avatar_url'];
      });
    } catch (e) {
      print("❌ Gagal ambil data user: $e");
      setState(() {
        username = 'Gagal Ambil Nama';
        avatarUrl = null;
      });
    }
  }

  Future<void> _logout() async {
    loggedInUserId = '';
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
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? NetworkImage(avatarUrl!)
                        : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                username,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ListTile(
                onTap: () async {
                  await Get.to(() => const EditAccountScreen());
                  _loadUser(); // refresh data setelah update
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
