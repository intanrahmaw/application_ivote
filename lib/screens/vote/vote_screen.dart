import 'package:application_ivote/screens/vote/vote_succes_screen.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/global_user.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';

final supabase = Supabase.instance.client;

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final int _selectedIndex = 1; // Halaman ini adalah indeks ke-1

  List<Map<String, dynamic>> candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

  // --- SEMUA LOGIKA ANDA TETAP SAMA & AMAN ---
  Future<void> fetchCandidates() async {
    try {
      final response = await supabase
          .from('candidates')
          .select(
            'candidate_id, nama, image_url, elections_id, elections!inner(is_active)',
          )
          .eq('elections.is_active', true);

      if (mounted) {
        setState(() {
          candidates = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kandidat');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> voteForCandidate(String candidateId, String electionId) async {
    try {
      final candidate =
          await supabase
              .from('candidates')
              .select('organisasi')
              .eq('candidate_id', candidateId)
              .maybeSingle();
      final selectedOrg = candidate?['organisasi'];
      if (selectedOrg == null) {
        Get.snackbar('Error', 'Organisasi tidak ditemukan.');
        return;
      }
      final orgCandidates = await supabase
          .from('candidates')
          .select('candidate_id')
          .eq('organisasi', selectedOrg);
      final candidateIds = orgCandidates.map((c) => c['candidate_id']).toList();
      final existingVote = await supabase
          .from('votes')
          .select('vote_id')
          .eq('user_id', loggedInUserId)
          .inFilter('candidate_id', candidateIds);

      if (existingVote.isNotEmpty) {
        Get.snackbar(
          'Vote Gagal',
          'Kamu sudah memilih kandidat dari organisasi ini.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      await supabase.from('votes').insert({
        'user_id': loggedInUserId,
        'candidate_id': candidateId,
        'elections_id': electionId,
      });
      Get.offAll(() => const VoteSuccessScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal vote: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handleVote(Map<String, dynamic> candidate) {
    final candidateId = candidate['candidate_id'];
    final electionId = candidate['elections_id'];
    voteForCandidate(candidateId, electionId);
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
  // --- AKHIR DARI LOGIKA ANDA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Halaman Voting"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Widget helper untuk membangun body utama
  Widget _buildBody() {
    if (candidates.isEmpty) {
      return _buildEmptyState();
    }

    // Gunakan ListView agar kita bisa menambahkan header di atas list
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Judul sebelum daftar kandidat
        const Text(
          "Daftar Kandidat",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        // Menggunakan operator spread (...) untuk memasukkan list widget ke dalam children
        ...candidates
            .map((candidate) => _buildCandidateCard(candidate))
            .toList(),
      ],
    );
  }

  // Widget untuk menampilkan pesan jika tidak ada kandidat
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Tidak Ada Pemilihan Aktif",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const Text(
            "Silakan kembali lagi nanti.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget untuk setiap kartu kandidat
  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final imageUrl = candidate['image_url'] ?? '';
    final nama = candidate['nama'] ?? 'Nama Kandidat';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child:
                  imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _handleVote(candidate),
              icon: const Icon(Icons.how_to_vote, size: 18),
              label: const Text("Vote"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
