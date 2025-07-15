import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _supabase = Supabase.instance.client;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('username')
          .eq('user_id', user.id)
          .single();

      setState(() {
        _usernameController.text = data['username'] ?? '';
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _updateAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
      );
      return;
    }

    try {
      // Update username di tabel users
      await _supabase.from('users').update({
        'username': _usernameController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      // Jika password diisi dan cocok, update password via auth
      if (newPassword.isNotEmpty) {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui akun: $e')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_usernameController, 'Username'),
            const SizedBox(height: 15),
            _buildTextField(_passwordController, 'Password Baru', obscureText: true),
            const SizedBox(height: 15),
            _buildTextField(_confirmPasswordController, 'Tulis Ulang Password', obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
