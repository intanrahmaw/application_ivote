import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../utils/app_routes.dart';
import '../../utils/global_user.dart';
import 'register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (password != _ulangPasswordController.text.trim()) {
      Get.snackbar('Error', 'Password tidak cocok',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId != null) {
        final now = DateTime.now().toIso8601String();

        await Supabase.instance.client.from('users').insert({
          'user_id': userId,
          'username': _usernameController.text.trim(),
          'password': password,
          'nama': _namaController.text.trim(),
          'email': email,
          'alamat': _alamatController.text.trim(),
          'no_hp': '+62${_teleponController.text.trim()}',
          'created_at': now,
          'updated_at': now,
        });

        Get.snackbar('Berhasil', 'Registrasi berhasil! Silakan cek email Anda.',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      }
    } on AuthException catch (e) {
      Get.snackbar('Gagal Registrasi', e.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _ulangPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bagian atas: Judul "Buat Akun" (tanpa tombol back atas)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.03), // Spasi atas yang sedikit lebih responsif
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Buat Akun',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Bagian tengah: Semua input fields
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildInputField('Nama Lengkap', _namaController),
                            _buildInputField('Username', _usernameController),
                            _buildInputField(
                              'Email',
                              _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || !GetUtils.isEmail(value)) {
                                  return 'Email tidak valid';
                                }
                                return null;
                              },
                            ),
                            _buildInputField('Alamat', _alamatController),
                            Row(
                              children: [
                                // Rapikan tampilan inputan no hp
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  // Atur tinggi agar cocok dengan TextFormField
                                  height: 54, // Default height of TextFormField is around 54-56
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade400) // Tambah border agar terlihat sama
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '+62',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildInputField(
                                    'Nomor HP',
                                    _teleponController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'Password',
                              _passwordController,
                              obscure: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            _buildInputField(
                              'Ulangi Password',
                              _ulangPasswordController,
                              obscure: true,
                            ),
                          ],
                        ),

                        // Bagian bawah: Tombol Daftar dan Tombol Back
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                                : SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Daftar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 20), // Spasi antara tombol Daftar dan Back
                            TextButton(
                              onPressed: () => Get.back(), // Menggunakan Get.back() untuk kembali
                              child: Text(
                                'Sudah punya akun? Kembali ke Login',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02), // Spasi di bagian paling bawah
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder( // Tambah enabledBorder untuk konsistensi visual
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder( // Tambah focusedBorder
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.purple, width: 2), // Contoh focus color
          ),
          errorBorder: OutlineInputBorder( // Tambah errorBorder
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder( // Tambah focusedErrorBorder
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}