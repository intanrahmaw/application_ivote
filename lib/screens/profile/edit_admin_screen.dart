import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/global_user.dart';

class EditAdminAccountScreen extends StatefulWidget {
  
  const EditAdminAccountScreen({super.key});
  

  @override
  State<EditAdminAccountScreen> createState() => _EditAdminAccountScreenState();
}

class _EditAdminAccountScreenState extends State<EditAdminAccountScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _namaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  Future<void> _loadAccountData() async {
    try {
       print('LOGGED IN ADMIN ID: $loggedInUserId'); // ✅ Tambahkan ini

      final data = await supabase
          .from('admin')
          .select()
          .eq('admin_id', loggedInUserId)
          .maybeSingle();

      if (data == null) {
        throw Exception('Data admin tidak ditemukan');
      }

      setState(() {
        _usernameController.text = data['username'] ?? '';
        _namaController.text = data['nama'] ?? '';
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() => _saving = true);

      final updateData = {
        'username': _usernameController.text.trim(),
        'nama': _namaController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newPassword.isNotEmpty) {
        updateData['password'] = newPassword;
      }

      await supabase.from('admin').update(updateData).eq('admin_id', loggedInUserId);

      loggedInUserName = _usernameController.text.trim();

      Get.snackbar(
        'Sukses',
        'Akun berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offNamed('/profile');
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memperbarui akun: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool obscure = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: (val) {
          if (label.contains('Password Baru')) return null;
          if (val == null || val.trim().isEmpty) return '$label tidak boleh kosong';
          return null;
        },
        decoration: InputDecoration(
          hintText: label,
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
           
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namaController.dispose();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Edit Akun',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 24),
    _buildInput('Username', _usernameController),
    _buildInput('Nama Lengkap', _namaController),
    _buildInput('Password Baru', _passwordController, obscure: true),
    _buildInput('Konfirmasi Password', _confirmPasswordController, obscure: true), // tambahkan ini juga biar lengkap
    const SizedBox(height: 24), // jarak antara input dan tombol
    Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: _saving ? null : _updateAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ],
    )
  ],
),          ),
          ),
        ),
      );
  }
}
