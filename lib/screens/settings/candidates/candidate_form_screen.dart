import 'dart:io';
import 'package:application_ivote/models/elections_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_ivote/models/candidates_model.dart';
import 'package:application_ivote/services/candidate_supbase_service.dart';
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

  final _organisasiController = TextEditingController();
  final _labelController = TextEditingController();
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
      _organisasiController.text = _existingCandidate!.organisasi;
      _labelController.text = _existingCandidate!.label;
      _electionId = _existingCandidate!.electionId;
      _existingImageUrl = _existingCandidate!.imageUrl;
    }
    _loadElections();
  }

  Future<void> _loadElections() async {
    final response = await Supabase.instance.client
        .from('elections')
        .select();

    final now = DateTime.now();

    setState(() {
      _elections = (response as List)
          .map((e) => Elections.fromJson(e))
          .where((election) =>
              election.isActive == true &&
              election.endTime.isAfter(now))
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
          final fileName = 'candidates/${DateTime.now().millisecondsSinceEpoch}.jpg';

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
            organisasi: _organisasiController.text,
            label: _labelController.text,
            visi: _visiController.text,
            misi: _misiController.text,
            imageUrl: imageUrl,
          );
        } else {
          await _supabaseService.addCandidate(
            electionId: _electionId!,
            nama: _namaController.text,
            organisasi: _organisasiController.text,
            label: _labelController.text,
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
    _organisasiController.dispose();
    _labelController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    super.dispose();
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? '$hint tidak boleh kosong' : null,
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

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingCandidate != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? 'Edit Kandidat' : 'Tambah Kandidat',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 24),

                // Image Preview
                Center(
                  child: _imageFile != null
                      ? (kIsWeb
                          ? Image.network(_imageFile!.path, height: 160, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), height: 160, fit: BoxFit.cover))
                      : (_existingImageUrl != null
                          ? Image.network(_existingImageUrl!, height: 160, fit: BoxFit.cover)
                          : Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            )),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Pilih Foto Kandidat'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 24),

                _buildInputField('Nama Kandidat', _namaController),
                _buildInputField('Organisasi', _organisasiController),
                _buildInputField('Label', _labelController),
                _buildInputField('Visi', _visiController, maxLines: 3),
                _buildInputField('Misi', _misiController, maxLines: 5),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    value: _elections.any((e) => e.electionId == _electionId)
                        ? _electionId
                        : null,
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
                        value == null || value.isEmpty ? 'Pilih pemilihan terlebih dahulu' : null,
                    decoration: InputDecoration(
                      hintText: 'Pilih Pemilihan',
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.deepPurple, width: 2),
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

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isEdit ? 'Update' : 'Simpan',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
    );
  }
}