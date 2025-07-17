import 'package:flutter/material.dart';

class DetailCandidateScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const DetailCandidateScreen({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    String? imageUrl = candidate['image_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile ${candidate['nama']}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        automaticallyImplyLeading: false, // Hapus tombol back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto profil
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                      ),
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                    ),
            ),

            const SizedBox(height: 24),

            // Nama
            Text(
              candidate['nama'] ?? 'Tidak diketahui',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Kelas / Jurusan
            if (candidate['kelas'] != null || candidate['jurusan'] != null)
              Text(
                candidate['kelas'] ?? candidate['jurusan'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(height: 24),

            // Visi
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Visi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(candidate['visi'] ?? '-'),
            ),

            const SizedBox(height: 24),

            // Misi
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Misi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(candidate['misi'] ?? '-'),
            ),

            const SizedBox(height: 40),

            // Tombol kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
