import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/auth/login_screen.dart';
import 'package:application_ivote/screens/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  String username = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentSession?.user; // ✅ valid di v2.9.0
    print("🟡 Current User: $user");

    if (user == null) {
      Future.microtask(() {
        Get.offAll(() => const LoginScreen());
      });
      return;
    }

    try {
      final data = await supabase
          .from('users')
          .select('username')
          .eq('user_id', user.id)
          .single();

      setState(() {
        username = data['username'] ?? 'Pengguna';
      });
    } catch (e) {
      print("❌ Gagal ambil data user: $e");
      setState(() {
        username = 'Gagal Ambil Nama';
      });
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
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
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
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
                  _loadUser(); // refresh username setelah edit
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
