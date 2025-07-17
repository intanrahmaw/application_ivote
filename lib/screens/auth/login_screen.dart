import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../utils/global_user.dart';
import '../home/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _signIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Peringatan', 'Username dan password tidak boleh kosong',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cek apakah data cocok di tabel admin
      final adminResponse = await supabase
          .from('admin')
          .select('admin_id, nama')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (adminResponse != null) {
        final namaAdmin = adminResponse['nama'] ?? 'Admin';
        loggedInUserName = namaAdmin;
        loggedInUserRole = 'admin';

        Get.snackbar('Login Berhasil', 'Selamat datang, $namaAdmin!',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAll(() => const DashboardScreen());
        return;
      }

      // Jika bukan admin, coba cek tabel users
      final userResponse = await supabase
          .from('users')
          .select('nama')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (userResponse == null) {
        Get.snackbar('Login Gagal', 'Username atau password salah',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final namaUser = userResponse['nama'] ?? 'Pengguna';
      loggedInUserName = namaUser;
      loggedInUserRole = 'user';

      Get.snackbar('Berhasil Login', 'Selamat datang, $namaUser!',
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAll(() => const DashboardScreen());
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat login: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      Image.asset('assets/Image/logo.png', height: screenHeight * 0.3),
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'WELCOME TO IVOTE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.deepPurple)
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Get.to(() => const RegisterScreen()),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}