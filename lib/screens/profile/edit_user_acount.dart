import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/users_model.dart';

class EditUserAccountScreen extends StatefulWidget {
 final Users user;

  const EditUserAccountScreen({super.key, required this.user});

  @override
  State<EditUserAccountScreen> createState() => _EditUserAccountScreenState();
}

class _EditUserAccountScreenState extends State<EditUserAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.user.nama ?? '';
    _emailController.text = widget.user.email ?? '';
    _alamatController.text = widget.user.alamat ?? '';
    _noHpController.text = widget.user.noHp ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final fileName = 'avatars/$userId.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, imageBytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? avatarUrl = widget.user.avatarUrl;
    if (_selectedImage != null) {
      avatarUrl = await _uploadImage(widget.user.userId);
    }

    try {
      await SupabaseService().updateUser(
        userId: widget.user.userId,
        nama: _namaController.text,
        email: _emailController.text,
        alamat: _alamatController.text,
        noHp: _noHpController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        avatarUrl: avatarUrl,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Update error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui data")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.user.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Akun Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (avatarUrl != null && avatarUrl != ''
                                ? NetworkImage(avatarUrl)
                                : const AssetImage('assets/images/default_avatar.png')
                                    as ImageProvider),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Alamat wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _noHpController,
                      decoration: const InputDecoration(labelText: 'No HP'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'No HP wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password (opsional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
