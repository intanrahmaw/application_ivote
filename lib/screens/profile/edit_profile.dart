import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/utils/global_user.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final supabase = Supabase.instance.client;

  final _usernameController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nohpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? imageUrl;
  bool _loading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (loggedInUserId.isEmpty) return;

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('user_id', loggedInUserId)
          .single();

      setState(() {
        _usernameController.text = data['username'] ?? '';
        _namaController.text = data['nama'] ?? '';
        _emailController.text = data['email'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _nohpController.text = data['no_hp'] ?? '';
        imageUrl = data['avatar_url'];
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    const bucketName = 'avatars';
    final fileName =
        'profile_${loggedInUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final fileBytes = await imageFile.readAsBytes();

      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = supabase.storage.from(bucketName).getPublicUrl(fileName);
      return url;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload gambar gagal: $e')),
      );
      return null;
    }
  }

  Future<void> _updateAccount() async {
    if (loggedInUserId.isEmpty) return;

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isNotEmpty && password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
      );
      return;
    }

    String? uploadedImageUrl = imageUrl;

    if (_selectedImage != null) {
      uploadedImageUrl = await _uploadImage(_selectedImage!);
      if (uploadedImageUrl != null) {
        setState(() {
          imageUrl = uploadedImageUrl;
        });
      }
    }

    final updateData = {
      'username': _usernameController.text.trim(),
      'nama': _namaController.text.trim(),
      'email': _emailController.text.trim(),
      'alamat': _alamatController.text.trim(),
      'no_hp': _nohpController.text.trim(),
      'avatar_url': uploadedImageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (password.isNotEmpty) {
      updateData['password'] = password;
    }

    try {
      await supabase
          .from('users')
          .update(updateData)
          .eq('user_id', loggedInUserId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Akun'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (imageUrl != null && imageUrl!.isNotEmpty
                        ? NetworkImage(imageUrl!)
                        : null) as ImageProvider<Object>?,
                backgroundColor: Colors.grey[200],
                child: (_selectedImage == null &&
                        (imageUrl == null || imageUrl!.isEmpty))
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, 'Username'),
            _buildTextField(_namaController, 'Nama'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_alamatController, 'Alamat'),
            _buildTextField(_nohpController, 'No HP'),
            _buildTextField(_passwordController, 'Password Baru',
                obscureText: true),
            _buildTextField(_confirmPasswordController, 'Ulangi Password',
                obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateAccount,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Simpan',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _nohpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
