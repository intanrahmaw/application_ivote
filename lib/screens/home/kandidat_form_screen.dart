import 'package:flutter/material.dart';
import 'package:application_ivote/models/kandidat_model.dart';


class KandidatFormScreen extends StatefulWidget {
  final Kandidat? kandidat;
  const KandidatFormScreen({super.key, this.kandidat});

  @override
  State<KandidatFormScreen> createState() => _KandidatFormScreenState();
}

class _KandidatFormScreenState extends State<KandidatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nimController;
  late TextEditingController _prodiController;
  late TextEditingController _visiController;
  late TextEditingController _misiController;

  bool get _isEditing => widget.kandidat != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kandidat?.nama ?? '');
    _nimController = TextEditingController(text: widget.kandidat?.nim ?? '');
    _prodiController = TextEditingController(text: widget.kandidat?.prodi ?? '');
    _visiController = TextEditingController(text: widget.kandidat?.visi ?? '');
    _misiController = TextEditingController(text: widget.kandidat?.misi ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Logika untuk menyimpan data ke database/API
      // Jika _isEditing, lakukan update. Jika tidak, lakukan insert.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Form Ubah Kandidat' : 'Form Input Kandidat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_namaController, 'Nama'),
              const SizedBox(height: 16),
              _buildTextFormField(_nimController, 'NIM'),
              const SizedBox(height: 16),
              _buildTextFormField(_prodiController, 'Program Studi'),
              const SizedBox(height: 16),
              _buildTextFormField(_visiController, 'Visi', maxLines: 5),
              const SizedBox(height: 16),
              _buildTextFormField(_misiController, 'Misi', maxLines: 5),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}