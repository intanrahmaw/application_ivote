import 'package:flutter/material.dart';
import 'package:application_ivote/screens/profil_screen.dart';
import 'package:application_ivote/screens/edit_profil_screen.dart';
import 'package:application_ivote/widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Index untuk 'Profile'

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Logika navigasi antar halaman bottom nav bar di sini
    // Contoh:
    // if (index == 0) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    // } else if (index == 1) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
    // }
    // ... dan seterusnya
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah anda yakin untuk logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1), // Background hijau samar
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.arrow_back, // Menggunakan ikon panah sesuai gambar
                  size: 40,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Logika logout
                        Navigator.of(context).pop(); // Tutup dialog
                        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false); // Contoh navigasi ke LoginScreen setelah logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600], // Warna merah
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Tutup dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, // Warna ungu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Menghilangkan shadow
        title: const Text(
          'Admin', // Teks di AppBar
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Gambar Profil
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Admin', // Nama user di bawah gambar profil
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Opsi Edit Profil
            _buildProfileOption(
              icon: Icons.edit,
              text: 'Edit Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 15),

            // Opsi Logout
            _buildProfileOption(
              icon: Icons.logout,
              text: 'Logout',
              onTap: _showLogoutDialog, // Memanggil dialog logout
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero, // Menghilangkan margin bawaan Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 15),
              Text(
                text,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const Spacer(), // Dorong ikon ke kanan
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}