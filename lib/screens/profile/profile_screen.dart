import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.logout, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                'Apakah anda yakin untuk logout?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('Logout'),
              onPressed:
                  () => Navigator.of(context).pop(), // Tambahkan logika logout
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar menu untuk ditampilkan di list
    final List<Widget> menuItems = [
      ListTile(
        leading: const Icon(Icons.edit_outlined, color: Colors.black54),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Warna latar belakang abu-abu
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- Bagian Header Profil ---
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFEFE9FF),
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Admin',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- KARTU MENU ---
              // Container ini berfungsi sebagai 'kartu' putih
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // ClipRRect untuk memastikan sudut tumpul diterapkan pada ListView di dalamnya
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ListView.separated(
                    itemCount: menuItems.length,
                    shrinkWrap:
                        true, // Wajib agar ListView di dalam Column tidak error
                    physics:
                        const NeverScrollableScrollPhysics(), // Agar tidak bisa di-scroll sendiri
                    itemBuilder: (context, index) {
                      return menuItems[index];
                    },
                    // Builder untuk garis pemisah antar item
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF5F5F5), // Warna pemisah yang soft
                        indent: 16, // Jarak dari kiri
                        endIndent: 16, // Jarak dari kanan
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
