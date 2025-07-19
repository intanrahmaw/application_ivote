import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/users_model.dart';
import 'package:application_ivote/services/supabase_service.dart';

class UserFormScreen extends StatefulWidget {
  final Users? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _namaController.text = widget.user!.nama;
      _emailController.text = widget.user!.email;
      _noHpController.text = widget.user!.noHp.replaceAll("+62", "");
      _alamatController.text = widget.user!.alamat;
      _usernameController.text = widget.user!.username;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = SupabaseService();
    final isEdit = widget.user != null;

    try {
      if (isEdit &&
          _newPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _confirmPasswordController.text) {
        Get.snackbar('Error', 'Password dan konfirmasi tidak cocok',
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => _isLoading = false);
        return;
      }

      if (isEdit) {
        await service.updateUser(
          userId: widget.user!.userId,
          nama: _namaController.text,
          email: _emailController.text,
          alamat: _alamatController.text,
          noHp: '+62${_noHpController.text}',
          password: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
        );
      } else {
        await service.addUser(
          username: _usernameController.text,
          password: _passwordController.text,
          nama: _namaController.text,
          email: _emailController.text,
          alamat: _alamatController.text,
          noHp: '+62${_noHpController.text}',
        );
      }

      Get.snackbar(
        'Sukses',
        isEdit ? 'User berhasil diperbarui' : 'User berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed('/user');
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {bool obscure = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    final isPasswordBaru = hint.toLowerCase().contains('password baru');
    final isEdit = widget.user != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              // Validator khusus untuk password baru saat edit
              if (isEdit && isPasswordBaru) {
                return null; // password baru opsional
              }
              if (value == null || value.isEmpty) {
                return '$hint tidak boleh kosong';
              }
              return null;
            },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF0F0F0),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            child: const Text('+62', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _noHpController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor HP tidak boleh kosong';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Nomor HP hanya boleh angka';
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Form Edit User' : 'Form Input User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInputField('Nama', _namaController),
                  _buildInputField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                  _buildPhoneInput(),
                  _buildInputField('Alamat', _alamatController),
                  _buildInputField('Username', _usernameController),
                  if (!isEdit)
                    _buildInputField('Password', _passwordController, obscure: true),
                  if (isEdit) ...[
                    const SizedBox(height: 8),
                    const Text('Ubah Password (Opsional)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildInputField('Password Baru', _newPasswordController, obscure: true),
                    _buildInputField('Ulangi Password Baru', _confirmPasswordController, obscure: true),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  isEdit ? 'Update' : 'Simpan',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
