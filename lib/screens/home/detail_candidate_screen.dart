import 'package:flutter/material.dart';

class DetailCandidateScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const DetailCandidateScreen({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    String? imageUrl = candidate['image_url'];
    String nama = candidate['nama'] ?? 'Nama Kandidat';
    String detailInfo =
        candidate['kelas'] ?? candidate['jurusan'] ?? 'Detail Kandidat';
    String visi = candidate['visi'] ?? 'Visi kandidat belum diatur.';
    String misi = candidate['misi'] ?? 'Misi kandidat belum diatur.';

    return Scaffold(
      // extendBodyBehindAppBar memungkinkan body untuk berada di belakang AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // AppBar transparan agar background gradien terlihat
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol kembali akan muncul secara otomatis dengan warna yang sesuai
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        // Hapus padding dari SingleChildScrollView agar header menempel di tepi
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // --- BAGIAN HEADER ---
            Stack(
              clipBehavior:
                  Clip.none, // Izinkan CircleAvatar keluar dari batas Stack
              alignment: Alignment.center,
              children: [
                // Background gradien
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Beri sedikit lengkungan di bawah jika diinginkan
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                ),
                // Foto profil yang 'menggantung'
                Positioned(
                  bottom: -60, // Tarik CircleAvatar ke bawah
                  child: CircleAvatar(
                    radius: 65, // Radius luar sebagai border putih
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 60, // Radius dalam untuk gambar
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (imageUrl != null && imageUrl.isNotEmpty)
                              ? NetworkImage(imageUrl)
                              : null,
                      child:
                          (imageUrl == null || imageUrl.isEmpty)
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              )
                              : null,
                    ),
                  ),
                ),
              ],
            ),

            // Beri jarak untuk foto profil yang 'menggantung'
            const SizedBox(height: 70),

            // --- BAGIAN INFO NAMA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  const SizedBox(height: 4),
                  Text(
                    detailInfo,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- BAGIAN KONTEN VISI & MISI ---
            Padding(
              padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat kartu informasi (Visi/Misi)
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
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
                color: Colors.grey[600],
                height: 1.5, // Jarak antar baris
              ),
            ),
          ],
        ),
      ),
    );
  }
}
