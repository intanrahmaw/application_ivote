import 'dart:io';
import 'package:application_ivote/models/election_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_ivote/models/kandidat_model.dart';
import 'package:application_ivote/service/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CandidateFormScreen extends StatefulWidget {
  final Candidate? candidate;
  const CandidateFormScreen({super.key, this.candidate});

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
  List<Elections> _elections = [];

  @override
  void initState() {
    super.initState();
    _existingCandidate = widget.candidate;
if (_existingCandidate != null) {
  _namaController.text = _existingCandidate!.nama;
  _visiController.text = _existingCandidate!.visi;
  _misiController.text = _existingCandidate!.misi;
  _electionId = _existingCandidate!.electionId;
  _existingImageUrl = _existingCandidate!.imageUrl;
}
 _loadElections();
  }

  Future<void> _loadElections() async {
    final response = await Supabase.instance.client.from('elections').select();

    setState(() {
      _elections = (response as List)
          .map((e) => Elections.fromJson(e))
          .toList();
    });
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
              'candidate-image',
              fileName,
            );
          } else {
            final file = File(_imageFile!.path);
            imageUrl = await _supabaseService.uploadImage(
              file,
              'candidate-image',
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
            imageUrl: imageUrl,
          );
        } else {
          await _supabaseService.addCandidate(
            electionId: _electionId!,
            nama: _namaController.text,
            visi: _visiController.text,
            misi: _misiController.text,
            imageUrl: imageUrl,
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
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Form Kandidat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gambar preview
                  _imageFile != null
                      ? (kIsWeb
                          ? Image.network(_imageFile!.path, height: 160, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), height: 160, fit: BoxFit.cover))
                      : (_existingImageUrl != null
                          ? Image.network(_existingImageUrl!, height: 160, fit: BoxFit.cover)
                          : Container(
                              height: 160,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            )),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Pilih Foto Kandidat'),
                  ),
                  const SizedBox(height: 24),

                  // Nama
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kandidat',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Visi
                  TextFormField(
                    controller: _visiController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Visi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Visi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Misi
                  TextFormField(
                    controller: _misiController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Misi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Misi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Pemilihan
                 DropdownButtonFormField<String>(
  value: _elections.any((e) => e.electionId == _electionId) ? _electionId : null,
  items: _elections.map((e) {
    return DropdownMenuItem<String>(
      value: e.electionId,
      child: Text(e.judul),
    );
  }).toList(),
  onChanged: (val) {
    setState(() {
      _electionId = val;
    });
  },
  validator: (value) =>
      value == null || value.isEmpty
          ? 'Pilih pemilihan terlebih dahulu'
          : null,
  decoration: const InputDecoration(
    labelText: 'Pilih Pemilihan',
    border: OutlineInputBorder(),
  ),
),

                  const SizedBox(height: 24),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Kandidat'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
