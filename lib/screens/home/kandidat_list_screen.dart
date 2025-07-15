import 'package:flutter/material.dart';
import 'package:application_ivote/screens/home/kandidat_form_screen.dart';
import 'package:application_ivote/service/supabase_service.dart';
import 'package:application_ivote/models/kandidat_model.dart';

class KandidatListScreen extends StatefulWidget {
  const KandidatListScreen({super.key});

  @override
  State<KandidatListScreen> createState() => _KandidatListScreenState();
}

class _KandidatListScreenState extends State<KandidatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Candidate> _kandidatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKandidatList();
  }

  Future<void> _fetchKandidatList() async {
    setState(() => _isLoading = true);
    try {
      final result = await _supabaseService.fetchCandidates();
      _kandidatList = result.map((item) => Candidate.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Gagal fetch kandidat: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memuat data kandidat'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateAndRefresh({Candidate? kandidat}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateFormScreen(),
      ),
    );
    if (result == true) {
      _fetchKandidatList();
    }
  }

  void _showDeleteDialog(String candidateId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Apakah Anda yakin ingin menghapus data ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKandidat(candidateId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _deleteKandidat(String candidateId) async {
    try {
      await _supabaseService.deleteCandidate(candidateId);
      _fetchKandidatList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menghapus kandidat: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Visi', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Center(child: Text('Foto', style: TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(flex: 3, child: Center(child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildDataRow(Candidate kandidat, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text((index + 1).toString())),
          Expanded(flex: 3, child: Text(kandidat.nama)),
          Expanded(flex: 3, child: Text(kandidat.visi, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Center(
              child: kandidat.foto.isNotEmpty
                  ? Image.network(kandidat.foto, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _navigateAndRefresh(kandidat: kandidat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(kandidat.candidateId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Kandidat', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () => _navigateAndRefresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _kandidatList.isEmpty
                        ? const Center(child: Text("Tidak ada data kandidat"))
                        : ListView.builder(
                            itemCount: _kandidatList.length,
                            itemBuilder: (context, index) {
                              return _buildDataRow(_kandidatList[index], index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
