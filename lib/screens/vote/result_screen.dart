import 'package:application_ivote/screens/home/dashboard_screen.dart';
import 'package:application_ivote/screens/vote/vote_screen.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import '../../utils/global_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class VoteResultScreen extends StatefulWidget {
  const VoteResultScreen({super.key});
  

  @override
  State<VoteResultScreen> createState() => _VoteResultScreenState();
}

class _VoteResultScreenState extends State<VoteResultScreen> {
  int _currentIndex = 2; 
  bool isLoading = true;// Set index for "Hasil Vote"
  List<Map<String, dynamic>> results = [];
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    fetchVoteResults();
  }

  void _onItemTapped(int index) {
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          return;
        case 1:
          DashboardAdminMenu.show(context); // submenu setting
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

  Future<void> fetchVoteResults() async {
  try {
    // Ambil kandidat dengan election aktif
    final candidates = await supabase
        .from('candidates')
        .select('*, elections!inner(is_active)')
        .eq('elections.is_active', true);

    // Ambil semua vote
    final votes = await supabase.from('votes').select();

    // Ambil semua ID kandidat aktif
    final activeCandidateIds = candidates
        .map((c) => c['candidate_id'].toString())
        .toList();

    // Hitung suara hanya untuk kandidat aktif
    Map<String, int> voteCounts = {};
    for (var vote in votes) {
      String candidateId = vote['candidate_id'].toString();
      if (activeCandidateIds.contains(candidateId)) {
        voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
      }
    }

    int total = voteCounts.values.fold(0, (sum, count) => sum + count);

    // Gabungkan data kandidat dan jumlah suara
    List<Map<String, dynamic>> merged = candidates.map((candidate) {
      final id = candidate['candidate_id'].toString();
      final count = voteCounts[id] ?? 0;
      return {
        'nama': candidate['nama'],
        'image_url': candidate['image_url'],
        'vote_count': count,
      };
    }).toList();

    merged.sort((a, b) => b['vote_count'].compareTo(a['vote_count']));

    setState(() {
      results = merged;
      totalVotes = total;
      isLoading = false;
    });
  } catch (e) {
    print("Gagal memuat hasil voting: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hasil Voting"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Total Vote Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Total suara masuk",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$totalVotes",
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List of Candidates
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        final vote = item['vote_count'] as int;
                        final percent = totalVotes == 0 ? 0.0 : vote / totalVotes;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        item['image_url'] != null && item['image_url'] != ''
                                            ? NetworkImage(item['image_url'])
                                            : null,
                                    child: item['image_url'] == null || item['image_url'] == ''
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['nama'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${(percent * 100).toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  backgroundColor: Colors.black,
                                  color: Colors.white,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$vote suara",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ]
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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