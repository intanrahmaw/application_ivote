import 'package:flutter/material.dart';
import 'package:application_ivote/screens/home/kandidat_form_screen.dart';
import 'package:application_ivote/models/kandidat_model.dart';

class KandidatListScreen extends StatefulWidget {
  const KandidatListScreen({super.key});

  @override
  State<KandidatListScreen> createState() => _KandidatListScreenState();
}

class _KandidatListScreenState extends State<KandidatListScreen> {
  // Data dummy
  final List<Kandidat> _kandidatList = [
    Kandidat(
      id: 1,
      nama: 'Intan',
      nim: '220102027',
      prodi: 'TRPL',
      visi: 'Visi Intan',
      misi: 'Misi Intan',
    ),
    Kandidat(
      id: 2,
      nama: 'Theo',
      nim: '220102028',
      prodi: 'TRPL',
      visi: 'Visi Theo',
      misi: 'Misi Theo',
    ),
    Kandidat(
      id: 3,
      nama: 'Meisya',
      nim: '220102029',
      prodi: 'TRPL',
      visi: 'Visi Meisya',
      misi: 'Misi Meisya',
    ),
  ];

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Apakah anda yakin, menghapus data ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('Hapus'),
              onPressed: () {
                setState(() {
                  _kandidatList.removeWhere((k) => k.id == id);
                });
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _navigateAndRefresh(BuildContext context, {Kandidat? kandidat}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KandidatFormScreen(kandidat: kandidat),
      ),
    );
    setState(() {});
  }

  Widget _buildHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
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
          Expanded(flex: 1, child: Text('No', style: headerStyle)),
          Expanded(flex: 3, child: Text('Nama', style: headerStyle)),
          Expanded(flex: 3, child: Text('Prodi', style: headerStyle)),
          Expanded(
            flex: 2,
            child: Center(child: Text('Foto', style: headerStyle)),
          ),
          Expanded(
            flex: 3,
            child: Center(child: Text('Aksi', style: headerStyle)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(Kandidat kandidat, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text((index + 1).toString())),
          Expanded(flex: 3, child: Text(kandidat.nama)),
          Expanded(flex: 3, child: Text(kandidat.prodi)),
          const Expanded(
            flex: 2,
            child: Center(
              child: Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: 20,
                    ),
                    onPressed:
                        () => _navigateAndRefresh(context, kandidat: kandidat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteDialog(kandidat.id),
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
        title: const Text(
          'Kandidat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
       
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
              ), // Padding hanya di kanan
              child: ElevatedButton(
                onPressed: () => _navigateAndRefresh(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text('Tambah'),
              ),
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
                child: ListView.builder(
                  itemCount: _kandidatList.length,
                  itemBuilder: (context, index) {
                    final kandidat = _kandidatList[index];
                    return _buildDataRow(kandidat, index);
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
