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
    print('User ID saat initState: $loggedInUserId'); // Debug
  }

  Future<void> fetchCandidates() async {
    final response = await supabase.from('candidates').select();
    setState(() {
      candidates = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> voteForCandidate(String candidateId) async {
    print('voteForCandidate dipanggil');
    print('User ID: $loggedInUserId');
    print('Candidate ID: $candidateId');

    if (loggedInUserId.isEmpty) {
      Get.snackbar('Error', 'Anda belum login');
      return;
    }

    final existing = await supabase
        .from('votes')
        .select()
        .eq('user_id', loggedInUserId)
        .maybeSingle();

    if (existing != null) {
      Get.snackbar('Gagal', 'Anda sudah melakukan vote.');
      return;
    }

    await supabase.from('votes').insert({
      'user_id': loggedInUserId,
      'candidate_id': candidateId,
    });

    Get.snackbar('Sukses', 'Vote berhasil dikirim!');
    await Future.delayed(const Duration(seconds: 1));
    Get.offAll(() => const DashboardScreen());
  }

  void _handleVote(String candidateId) {
    print("Vote button diklik untuk ID kandidat: $candidateId");
    voteForCandidate(candidateId);
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Get.offAll(() => const DashboardScreen());
        break;
      case 1:
        break;
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
                print("Candidate ID dari index $index: $candidateId"); // Debug

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
                        onPressed: () => _handleVote(candidateId),
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
