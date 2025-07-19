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
  final int _selectedIndex = 0;
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> kandidatList = [];
  List<Map<String, dynamic>> filteredList = [];

  DateTime? endTime;
  Timer? countdownTimer;
  Duration remainingTime = Duration.zero;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKandidat();
    _fetchElectionEndTime();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchKandidat() async {
    try {
      final response = await supabase
          .from('candidates')
          .select('*, elections!inner(is_active)')
          .eq('elections.is_active', true);

      if (mounted) {
        setState(() {
          kandidatList = List<Map<String, dynamic>>.from(response);
          filteredList = kandidatList;
        });
      }
    } catch (e) {
      print('Gagal memuat kandidat aktif: $e');
    }
  }

  void _fetchElectionEndTime() async {
    try {
      final response = await supabase
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
      if (mounted && endTime != null) {
        setState(() {
          remainingTime = endTime!.difference(now).isNegative
              ? Duration.zero
              : endTime!.difference(now);
        });
      }
    });
  }

  void _onSearchChanged() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      filteredList = kandidatList.where((k) {
        final nama = (k['nama'] ?? '').toLowerCase();
        final organisasi = (k['organisasi'] ?? '').toLowerCase();
        final label = (k['label'] ?? '').toLowerCase();
        return nama.contains(keyword) ||
            organisasi.contains(keyword) ||
            label.contains(keyword);
      }).toList();
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
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
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Text(
          loggedInUserName.isNotEmpty
              ? loggedInUserName.capitalizeFirst!
              : 'Pengguna',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
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
            if (filteredList.isEmpty)
              const Center(child: Text('Tidak ada kandidat ditemukan'))
            else
              ...filteredList.map((k) => _buildKandidatCard(k)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'cari kandidat...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    int days = remainingTime.inDays;
    int hours = remainingTime.inHours % 24;
    int minutes = remainingTime.inMinutes % 60;
    int seconds = remainingTime.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.hourglass_bottom, color: Colors.white),
              SizedBox(width: 8),
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

  Widget _buildTimeItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildKandidatCard(Map<String, dynamic> kandidat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                kandidat['image_url'] != null && kandidat['image_url'] != ''
                    ? NetworkImage(kandidat['image_url'])
                    : null,
            backgroundColor: Colors.grey[300],
            child:
                kandidat['image_url'] == null || kandidat['image_url'] == ''
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  kandidat['label'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailCandidateScreen(candidate: kandidat),
                ),
              );
            },
            child: const Text('Lihat', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
