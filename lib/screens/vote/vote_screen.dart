import 'package:application_ivote/screens/vote/vote_succes_screen.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:application_ivote/screens/vote/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_ivote/screens/home/dashboard_screen.dart';
import '../../utils/global_user.dart';

final supabase = Supabase.instance.client;

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  int _currentIndex = 1;
  List<Map<String, dynamic>> candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    print('User ID saat initState: $loggedInUserId');
  }

  Future<void> fetchCandidates() async {
    try {
      final response = await supabase
          .from('candidates')
          .select('candidate_id, nama, image_url, elections_id, elections!inner(is_active)')
          .eq('elections.is_active', true);

      setState(() {
        candidates = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e, st) {
      print('❌ Gagal fetch candidates: $e');
      Get.snackbar('Error', 'Gagal memuat data kandidat');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> voteForCandidate(String candidateId, String electionId) async {
  try {
    // Ambil data kandidat untuk mendapatkan organisasi-nya
    final candidate = await supabase
        .from('candidates')
        .select('organisasi')
        .eq('candidate_id', candidateId)
        .maybeSingle();

    final selectedOrg = candidate?['organisasi'];

    if (selectedOrg == null) {
      Get.snackbar('Error', 'Organisasi tidak ditemukan.');
      return;
    }

    // Ambil semua kandidat yang memiliki organisasi yang sama
    final orgCandidates = await supabase
        .from('candidates')
        .select('candidate_id')
        .eq('organisasi', selectedOrg);

    final candidateIds = orgCandidates.map((c) => c['candidate_id']).toList();

    // Cek apakah user sudah pernah vote kandidat dari organisasi yang sama
    final existingVote = await supabase
        .from('votes')
        .select('vote_id')
        .eq('user_id', loggedInUserId)
        .inFilter('candidate_id', candidateIds);

    if (existingVote.isNotEmpty) {
      Get.snackbar('Vote Gagal',
          'Kamu sudah memilih kandidat dari organisasi ini.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Jika belum pernah vote, simpan vote
    await supabase.from('votes').insert({
      'user_id': loggedInUserId,
      'candidate_id': candidateId,
      'elections_id': electionId,
    });

    Get.offAll(() => const VoteSuccessScreen());
  } catch (e) {
    print('❌ ERROR saat vote: $e');
    Get.snackbar('Error', 'Gagal vote: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}

  void _handleVote(Map<String, dynamic> candidate) {
    final candidateId = candidate['candidate_id'];
    final electionId = candidate['elections_id'];

    voteForCandidate(candidateId, electionId);
  }

  void _onItemTapped(int index) {
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          return;
        case 1:
          DashboardAdminMenu.show(context);
          return;
        case 2:
          Get.offAllNamed('/result');
          return;
        case 3:
          Get.offAllNamed('/profile');
          return;
      }
    } else {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          return;
        case 1:
          Get.offAllNamed('/vote');
          return;
        case 2:
          Get.offAllNamed('/result');
          return;
        case 3:
          Get.offAllNamed('/profile');
          return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Vote",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final imageUrl = candidate['image_url'] ?? '';
                final nama = candidate['nama'] ?? '';
                final candidateId = candidate['candidate_id'].toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E9F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        size: 50, color: Colors.grey),
                              )
                            : const Icon(Icons.account_circle,
                                size: 50, color: Colors.deepPurple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          nama,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ElevatedButton(
                        key: Key('vote_button_$candidateId'),
                        onPressed: () => _handleVote(candidate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD1B5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text("Vote"),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote), label: 'Vote'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Hasil Vote'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
