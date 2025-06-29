import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _adminController = TextEditingController(text: 'Admin');
  final TextEditingController _intanController = TextEditingController(text: 'Intan');
  final TextEditingController _intan21Controller = TextEditingController(text: 'Intan21');
  final TextEditingController _intan12aController = TextEditingController(text: 'Intan12'); // Misal: Email
  final TextEditingController _intan12bController = TextEditingController(text: 'Intan12'); // Misal: Password

  @override
  void dispose() {
    _adminController.dispose();
    _intanController.dispose();
    _intan21Controller.dispose();
    _intan12aController.dispose();
    _intan12bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Gambar Profil (mirip dengan halaman profil)
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
            const SizedBox(height: 30),

            // Form Input
            _buildTextField(controller: _adminController, hintText: 'Admin'),
            const SizedBox(height: 15),
            _buildTextField(controller: _intanController, hintText: 'Intan'),
            const SizedBox(height: 15),
            _buildTextField(controller: _intan21Controller, hintText: 'Intan21'),
            const SizedBox(height: 15),
            _buildTextField(controller: _intan12aController, hintText: 'Intan12'),
            const SizedBox(height: 15),
            _buildTextField(controller: _intan12bController, hintText: 'Intan12'),
            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Logika untuk menyimpan perubahan profil
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil disimpan!')),
                  );
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Warna ungu
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Menghilangkan border
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}