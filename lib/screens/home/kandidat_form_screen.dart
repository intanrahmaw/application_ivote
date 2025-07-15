import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_ivote/models/kandidat_model.dart';
import 'package:application_ivote/service/supabase_service.dart';

class CandidateFormScreen extends StatefulWidget {
  const CandidateFormScreen({super.key});

  @override
  State<CandidateFormScreen> createState() => _CandidateFormScreenState();
}

class _CandidateFormScreenState extends State<CandidateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  final _namaController = TextEditingController();
  final _visiController = TextEditingController();
  final _misiController = TextEditingController();
  String? _electionId;

  bool _isLoading = false;
  Candidate? _existingCandidate;
  XFile? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Candidate) {
      _existingCandidate = Get.arguments as Candidate;
      _namaController.text = _existingCandidate!.nama;
      _visiController.text = _existingCandidate!.visi;
      _misiController.text = _existingCandidate!.misi;
      _electionId = _existingCandidate!.electionId;
      _existingImageUrl = _existingCandidate!.foto;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl = _existingImageUrl;

        if (_imageFile != null) {
          final fileName =
              'candidates/${DateTime.now().millisecondsSinceEpoch}.jpg';

          if (kIsWeb) {
            final imageBytes = await _imageFile!.readAsBytes();
            imageUrl = await _supabaseService.uploadImageBytes(
              imageBytes,
              'candidates-images',
              fileName,
            );
          } else {
            final file = File(_imageFile!.path);
            imageUrl = await _supabaseService.uploadImage(
              file,
              'candidates-images',
              fileName,
            );
          }
        }

        if (_existingCandidate != null) {
          await _supabaseService.updateCandidate(
            candidateId: _existingCandidate!.candidateId,
            electionId: _electionId!,
            nama: _namaController.text,
            visi: _visiController.text,
            misi: _misiController.text,
            fotoUrl: imageUrl,
          );
        } else {
          await _supabaseService.addCandidate(
            electionId: _electionId!,
            nama: _namaController.text,
            visi: _visiController.text,
            misi: _misiController.text,
            fotoUrl: imageUrl,
          );
        }

        Get.back(result: true);
      } catch (e) {
        Get.snackbar('Error', 'Gagal menyimpan kandidat: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingCandidate == null ? 'Tambah Kandidat' : 'Edit Kandidat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Gambar preview
              _imageFile != null
                  ? (kIsWeb
                      ? Image.network(_imageFile!.path, height: 150)
                      : Image.file(File(_imageFile!.path), height: 150))
                  : (_existingImageUrl != null
                      ? Image.network(_existingImageUrl!, height: 150)
                      : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 50),
                        )),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Foto Kandidat'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Kandidat'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _visiController,
                decoration: const InputDecoration(labelText: 'Visi'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Visi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _misiController,
                decoration: const InputDecoration(labelText: 'Misi'),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Misi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              // Input manual electionId (bisa diganti dropdown kalau perlu)
              TextFormField(
                initialValue: _electionId,
                decoration: const InputDecoration(labelText: 'ID Pemilihan'),
                onChanged: (val) => _electionId = val,
                validator: (value) =>
                    value == null || value.isEmpty ? 'ID Pemilihan wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Kandidat'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
