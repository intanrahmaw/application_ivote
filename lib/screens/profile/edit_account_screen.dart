import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/global_user.dart';
import '../../screens/auth/login_screen.dart';

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
  final _noHpController = TextEditingController();
  final _avatarController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  late String tableName;

  @override
  void initState() {
    super.initState();
    tableName = (loggedInUserRole == 'admin') ? 'admin' : 'users';
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    try {
      final data = await supabase
          .from(tableName)
          .select()
          .eq('username', loggedInUserName)
          .single();

      setState(() {
        _usernameController.text = data['username'] ?? '';
        _namaController.text = data['nama'] ?? '';
        _emailController.text = data['email'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _noHpController.text = data['no_hp'] ?? '';
        _avatarController.text = data['avatar_url'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _updateAccount() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
        );
      }
      return;
    }

    try {
      final updateData = {
        'username': _usernameController.text.trim(),
        'nama': _namaController.text.trim(),
        'avatar_url': _avatarController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (tableName == 'users') {
        updateData.addAll({
          'email': _emailController.text.trim(),
          'alamat': _alamatController.text.trim(),
          'no_hp': _noHpController.text.trim(),
        });
      }

      await supabase
          .from(tableName)
          .update(updateData)
          .eq('username', loggedInUserName);

      if (newPassword.isNotEmpty) {
        // Jika kamu menyimpan password secara manual, tambahkan di sini
        await supabase
            .from(tableName)
            .update({'password': newPassword})
            .eq('username', loggedInUserName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui akun: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _avatarController.dispose();
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
            if (_avatarController.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  _avatarController.text,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.account_circle, size: 120),
                ),
              ),
            const SizedBox(height: 15),
            _buildTextField(_avatarController, 'Avatar URL'),
            const SizedBox(height: 15),
            _buildTextField(_usernameController, 'Username'),
            const SizedBox(height: 15),
            _buildTextField(_namaController, 'Nama Lengkap'),
            if (tableName == 'users') ...[
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 15),
              _buildTextField(_alamatController, 'Alamat'),
              const SizedBox(height: 15),
              _buildTextField(_noHpController, 'No. HP'),
            ],
            const SizedBox(height: 15),
            _buildTextField(_passwordController, 'Password Baru', obscureText: true),
            const SizedBox(height: 15),
            _buildTextField(_confirmPasswordController, 'Tulis Ulang Password',
                obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
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
