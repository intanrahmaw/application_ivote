import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'detail_candidate_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- PERUBAHAN KUNCI 1 ---
  // Karena ini adalah halaman Dashboard, indeksnya sudah pasti 0.
  // Tidak perlu diubah, jadi kita buat `final`.
  final int _selectedIndex = 0;

  List<Map<String, dynamic>> kandidatList = [];
  DateTime? endTime;
  Timer? countdownTimer;
  Duration remainingTime = Duration.zero;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchKandidat();
    _fetchElectionEndTime();
  }

  void _fetchKandidat() async {
    try {
      final response = await supabase
          .from('candidates')
          .select('*, elections!inner(is_active)')
          .eq('elections.is_active', true);

      // Pastikan widget masih ada sebelum memanggil setState
      if (mounted) {
        setState(() {
          kandidatList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Gagal memuat kandidat aktif: $e');
    }
  }

  void _fetchElectionEndTime() async {
    try {
      final response =
          await supabase
              .from('elections')
              .select('end_time')
              .order('end_time', ascending: false)
              .limit(1)
              .single();

      if (mounted && response['end_time'] != null) {
        setState(() {
          endTime = DateTime.parse(response['end_time']);
          _startCountdown();
        });
      }
    } catch (e) {
      print('Gagal memuat waktu akhir pemilu: $e');
    }
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          if (endTime != null) {
            remainingTime =
                endTime!.difference(now).isNegative
                    ? Duration.zero
                    : endTime!.difference(now);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  // --- PERUBAHAN KUNCI 2 ---
  // Fungsi ini sekarang HANYA untuk navigasi. Tidak perlu setState.
  void _onItemTapped(int index) {
    // Jika user mengklik ikon yang sudah aktif, tidak perlu melakukan apa-apa.
    if (index == _selectedIndex) return;

    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break; // Menggunakan break lebih umum daripada return di switch
        case 1:
          // Ini adalah kasus khusus, hanya menampilkan menu, tidak navigasi halaman.
          DashboardAdminMenu.show(context);
          break;
        case 2:
          Get.offAllNamed('/result');
          break;
        case 3:
          Get.offAllNamed('/profile');
          break;
      }
    } else {
      // Untuk role 'user'
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          Get.offAllNamed('/vote');
          break;
        case 2:
          Get.offAllNamed('/result');
          break;
        case 3:
          Get.offAllNamed('/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUserRole.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        // ... kode AppBar Anda tidak berubah ...
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Text(
          ' ${loggedInUserName.isNotEmpty ? loggedInUserName.capitalizeFirst! : 'Pengguna'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      // ... body Anda tidak berubah ...
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerCard(),
            const SizedBox(height: 24.0),
            const Text(
              'Kandidat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            if (kandidatList.isEmpty)
              const Center(child: Text('Belum ada kandidat tersedia'))
            else
              ...kandidatList.map(
                (k) => Column(
                  children: [
                    _buildKandidatCard(k),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
          ],
        ),
      ),
      // --- PERUBAHAN KUNCI 3 ---
      // Kirim _selectedIndex (yang nilainya 0) dan fungsi navigasi ke navbar.
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // --- Semua Widget _build... Anda tidak perlu diubah ---
  Widget _buildTimerCard() {
    // ... kode tidak berubah
    int days = remainingTime.inDays;
    int hours = remainingTime.inHours % 24;
    int minutes = remainingTime.inMinutes % 60;
    int seconds = remainingTime.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 77, 55, 114),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.hourglass_empty, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Waktu tersisa untuk pemilu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeItem('$days', 'Hari'),
              _buildTimeItem('$hours', 'Jam'),
              _buildTimeItem('$minutes', 'Menit'),
              _buildTimeItem('$seconds', 'Detik'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // ... kode tidak berubah
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: const [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'cari kandidat...',
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String value, String label) {
    // ... kode tidak berubah
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildKandidatCard(Map<String, dynamic> kandidat) {
    // ... kode tidak berubah
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                kandidat['image_url'] != null && kandidat['image_url'] != ""
                    ? NetworkImage(kandidat['image_url'])
                    : null,
            backgroundColor: Colors.grey[300],
            radius: 24,
            child:
                kandidat['image_url'] == null || kandidat['image_url'] == ""
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kandidat['nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  kandidat['organisasi'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  kandidat['label'] ?? '-',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailCandidateScreen(candidate: kandidat),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'lihat profile',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}
