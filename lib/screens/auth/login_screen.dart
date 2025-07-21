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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _signIn() async {
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Peringatan', 'Username dan password tidak boleh kosong',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Coba login sebagai admin
      var admin = await supabase
          .from('admin')
          .select('admin_id, nama, username')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (admin != null) {
        loggedInUserName = admin['username'];
        loggedInUserId = admin['admin_id'];
        loggedInUserNama = admin['nama'];

        Get.snackbar('Login Berhasil', 'Selamat datang, ${admin['nama']}!',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAll(() => DashboardScreen());
        return;
      }

      // Jika bukan admin, cek user biasa
      var user = await supabase
          .from('users')
          .select('user_id, nama, username')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (user == null) {
        Get.snackbar('Login Gagal', 'Username atau password salah',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      loggedInUserName = user['username'];
      loggedInUserNama = user['nama']; // simpan nama lengkap user
      loggedInUserId = user['user_id'];
      loggedInUserRole = 'user';

      Get.snackbar('Berhasil Login', 'Selamat datang, ${user['nama']}!',
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAll(() => DashboardScreen());
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat login: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    var tinggi = MediaQuery.of(context).size.height;
    var lebar = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: lebar * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: tinggi * 0.04),
                      Image.asset('assets/Image/logo.png', height: tinggi * 0.3),
                      SizedBox(height: tinggi * 0.02),
                      Text(
                        'WELCOME TO IVOTE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: tinggi * 0.04),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: tinggi * 0.05),
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.deepPurple)
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
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => RegisterScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: tinggi * 0.04),
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
