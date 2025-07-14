import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/usermodels.dart';
import '../../services/supabase_service.dart';

class UserFormScreen extends StatefulWidget {
  final AppUser? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _namaController.text = widget.user!.nama;
      _emailController.text = widget.user!.email;
      _noHpController.text = widget.user!.noHp;
      _alamatController.text = widget.user!.alamat;
      _usernameController.text = widget.user!.username;
    }
  }

  Widget buildInput(String hint, TextEditingController controller,
      {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: (value) =>
            value == null || value.isEmpty ? '$hint wajib diisi' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = SupabaseService();

    try {
      if (widget.user == null) {
        await service.addUser(
          username: _usernameController.text,
          password: _passwordController.text,
          nama: _namaController.text,
          email: _emailController.text,
          alamat: _alamatController.text,
          noHp: _noHpController.text,
        );
        Get.snackbar('Sukses', 'User berhasil ditambahkan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await service.updateUser(
          userId: widget.user!.userId,
          nama: _namaController.text,
          email: _emailController.text,
          alamat: _alamatController.text,
          noHp: _noHpController.text,
        );
        Get.snackbar('Sukses', 'User berhasil diperbarui',
            backgroundColor: Colors.green, colorText: Colors.white);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Form Input User',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildInput('Nama', _namaController),
              buildInput('Email', _emailController),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        hintText: '+62',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: buildInput('Nomor telepon', _noHpController),
                  ),
                ],
              ),
              buildInput('Alamat', _alamatController),
              buildInput('Username', _usernameController),
              if (!isEdit)
                buildInput('Password', _passwordController, isObscure: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? 'Update' : 'Simpan',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
