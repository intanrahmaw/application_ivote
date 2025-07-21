import 'package:flutter/material.dart';

class DetailCandidateScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const DetailCandidateScreen({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    String? imageUrl = candidate['image_url'];
    String nama = candidate['nama'] ?? 'Nama Kandidat';
    String organisasi = candidate['organisasi'] ?? 'Organisasi belum tersedia';
    String label = candidate['label'] ?? 'Label belum tersedia';
    String visi = candidate['visi'] ?? 'Visi kandidat belum diatur.';
    String misi = candidate['misi'] ?? 'Misi kandidat belum diatur.';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        title: const Text('Detail Kandidat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false, 
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // FOTO KANDIDAT
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(Icons.person, size: 100, color: Colors.grey),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // INFORMASI UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _infoRow(Icons.apartment, organisasi, Colors.blueGrey),
                  const SizedBox(height: 6),
                  _infoRow(Icons.label_important, label, Colors.teal, italic: true),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // VISI & MISI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Visi',
                    content: visi,
                    icon: Icons.visibility_outlined,
                    iconColor: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Misi',
                    content: misi,
                    icon: Icons.flag_outlined,
                    iconColor: Colors.green.shade700,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color, {bool italic = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
