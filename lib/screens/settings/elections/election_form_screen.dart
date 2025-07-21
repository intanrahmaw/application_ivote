import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/models/elections_model.dart';
import 'package:application_ivote/services/election_supabase_service.dart';

class ElectionFormScreen extends StatefulWidget {
  final Elections? election;

  const ElectionFormScreen({super.key, this.election});

  @override
  State<ElectionFormScreen> createState() => _ElectionFormScreenState();
}

class _ElectionFormScreenState extends State<ElectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.election != null) {
      _judulController.text = widget.election!.judul;
      _deskripsiController.text = widget.election!.deskripsi;
      _startTime = widget.election!.startTime;
      _endTime = widget.election!.endTime;
      _isActive = widget.election!.isActive;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _startTime == null || _endTime == null) return;

    setState(() => _isLoading = true);
    final service = SupabaseService();

    try {
      if (widget.election == null) {
        await service.addElection(
          judul: _judulController.text,
          deskripsi: _deskripsiController.text,
          startTime: _startTime!,
          endTime: _endTime!,
        );
      } else {
        await service.updateElection(
          electionId: widget.election!.electionId,
          judul: _judulController.text,
          deskripsi: _deskripsiController.text,
          startTime: _startTime!,
          endTime: _endTime!,
          isActive: _isActive,
        );
      }

      Get.snackbar(
        'Sukses',
        widget.election == null
            ? 'Pemilu berhasil ditambahkan'
            : 'Pemilu berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 1));
      Get.offNamed('/election'); // Ganti dengan rute halaman manajemen pemilu milikmu
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Widget _buildInputField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? '$hint tidak boleh kosong' : null,
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
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value != null ? value.toString().split(' ')[0] : 'Pilih $label',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.election != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Edit Pemilu' : 'Form Pemilu',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInputField('Judul Pemilu', _judulController),
                  _buildInputField('Deskripsi Pemilu', _deskripsiController, maxLines: 3),
                  _buildDatePicker('Tanggal Mulai', _startTime, () => _selectDateTime(true)),
                  _buildDatePicker('Tanggal Selesai', _endTime, () => _selectDateTime(false)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktifkan Pemilu'),
                    activeColor: Colors.deepPurple,
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 30),
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
                          onPressed: _isLoading ? null : _submitForm,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
