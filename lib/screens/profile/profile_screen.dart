import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/auth/login_screen.dart';// Pastikan Anda memiliki file login_screen.dart
import 'package:application_ivote/screens/profile/edit_profile.dart'; // Impor EditAccountScreen
// halaman login setelah logout

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
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        username = 'Tidak Dikenal';
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
      setState(() {
        username = 'Gagal Ambil Nama';
      });
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Hasil Vote'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // Navigasi sesuai index
        },
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
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditAccountScreen()));
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
