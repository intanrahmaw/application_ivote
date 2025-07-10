import 'package:application_ivote/models/elecction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/service/supabase_service.dart';

class ElectionFormScreen extends StatefulWidget {
  final Election? election;

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
          nama: _judulController.text,
          deskripsi: _deskripsiController.text,
          tanggalMulai: _startTime!,
          tanggalSelesai: _endTime!,
        );
        Get.snackbar('Sukses', 'Pemilu berhasil ditambahkan',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await service.updateElection(
          electionId: widget.election!.electionId,
          nama: _judulController.text,
          deskripsi: _deskripsiController.text,
          tanggalMulai: _startTime!,
          tanggalSelesai: _endTime!,
        );
        Get.snackbar('Sukses', 'Pemilu berhasil diperbarui',
            backgroundColor: Colors.green, colorText: Colors.white);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Pemilu' : 'Tambah Pemilu',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput('Judul Pemilu', _judulController),
              _buildInput('Deskripsi Pemilu', _deskripsiController),
              const SizedBox(height: 10),
              _buildDatePicker('Tanggal Mulai', _startTime, () => _selectDateTime(context, true)),
              _buildDatePicker('Tanggal Selesai', _endTime, () => _selectDateTime(context, false)),
              SwitchListTile(
                title: const Text('Aktifkan Pemilu'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? 'Update' : 'Simpan',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? '$hint wajib diisi' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Text(label),
      subtitle: Text(value != null ? value.toString().split(' ')[0] : 'Pilih tanggal'),
      trailing: const Icon(Icons.calendar_today, color: Colors.purple),
      onTap: onTap,
    );
  }
}
