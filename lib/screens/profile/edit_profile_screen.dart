import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 40),
            TextFormField(initialValue: 'Admin', decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextFormField(initialValue: 'Intan', decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextFormField(initialValue: 'Intan12', decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), suffixIcon: Icon(Icons.visibility_off))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}