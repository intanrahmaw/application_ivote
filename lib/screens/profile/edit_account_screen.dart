import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/models/admin_model.dart';
import 'package:get/get.dart';
import 'package:application_ivote/services/admin_supabase_service.dart';

class EditAccountScreen extends StatefulWidget {
  final Admin admin;

  const EditAccountScreen({super.key, required this.admin});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminSupabaseService service = AdminSupabaseService();

  late TextEditingController _namaController;
  late TextEditingController _usernameController;
  late TextEditingController _newPasswordController;

  File? _avatarImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.admin.nama);
    _usernameController = TextEditingController(text: widget.admin.username);
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? avatarUrl = widget.admin.avatarUrl;

    try {
      // Upload avatar jika ada perubahan
      if (_avatarImage != null) {
        final bytes = await _avatarImage!.readAsBytes();
        final fileName = 'avatars/${widget.admin.adminId}.jpg';

        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

        avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
      }

      // Update data admin
      await service.updateAdmin(
        adminId: widget.admin.adminId,
        username: _usernameController.text,
        nama: _namaController.text,
        password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
        avatarUrl: avatarUrl,
      );

      Get.snackbar('Sukses', 'Data akun admin berhasil diperbarui');
      if (mounted) Navigator.pop(context); // pastikan masih di context
    } catch (e) {
  Get.snackbar('Error', 'Gagal memperbarui data: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Akun Admin')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatarImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!)
                              : (widget.admin.avatarUrl != null
                                  ? NetworkImage(widget.admin.avatarUrl!) as ImageProvider
                                  : const AssetImage('assets/images/default_avatar.png')),
                          child: const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password Baru (opsional)'),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
