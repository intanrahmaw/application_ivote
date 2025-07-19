import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
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
  final int _selectedIndex = 2;

  bool isLoading = true;
  List<Map<String, dynamic>> results = [];
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    fetchVoteResults();
  }

  // --- SEMUA LOGIKA ANDA TETAP SAMA & AMAN ---
  Future<void> fetchVoteResults() async {
    try {
      final candidates = await supabase
          .from('candidates')
          .select('*, elections!inner(is_active)')
          .eq('elections.is_active', true);

      final votes = await supabase.from('votes').select();
      final activeCandidateIds =
          candidates.map((c) => c['candidate_id'].toString()).toList();

      Map<String, int> voteCounts = {};
      for (var vote in votes) {
        String candidateId = vote['candidate_id'].toString();
        if (activeCandidateIds.contains(candidateId)) {
          voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
        }
      }

      int total = voteCounts.values.fold(0, (sum, count) => sum + count);

      List<Map<String, dynamic>> merged =
          candidates.map((candidate) {
            final id = candidate['candidate_id'].toString();
            final count = voteCounts[id] ?? 0;
            return {
              'nama': candidate['nama'],
              'image_url': candidate['image_url'],
              'vote_count': count,
            };
          }).toList();

      merged.sort((a, b) => b['vote_count'].compareTo(a['vote_count']));

      if (mounted) {
        setState(() {
          results = merged;
          totalVotes = total;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          Get.offAllNamed('/dashboard');
          break;
        case 1:
          SubMenuAdmin.show(context);
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Hasil Voting"),
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

  Widget _buildBody() {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Hasil Voting Belum Tersedia",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Menggunakan ListView.builder agar lebih efisien dan mudah menambahkan header
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length + 1, // +1 untuk kartu header
      itemBuilder: (context, index) {
        // Item pertama adalah kartu header
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildTotalVotesCard(),
          );
        }
        // Item selanjutnya adalah kartu kandidat
        final resultIndex = index - 1;
        return _buildResultCard(results[resultIndex], resultIndex);
      },
    );
  }

  Widget _buildTotalVotesCard() {
    return Card(
      elevation: 5,
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.show_chart_rounded, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Suara Masuk",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  "$totalVotes Suara",
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item, int rank) {
    final vote = item['vote_count'] as int;
    final percent = totalVotes == 0 ? 0.0 : vote / totalVotes;
    final imageUrl = item['image_url'] ?? '';
    final nama = item['nama'] ?? 'Nama Kandidat';

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildRankIcon(rank), // Ikon Peringkat/Medali
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? const Icon(
                            Icons.person,
                            size: 25,
                            color: Colors.grey,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "${(percent * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[300],
                color: Colors.purple,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$vote suara",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank == 0) {
      return const Text("🥇", style: TextStyle(fontSize: 24));
    }
    if (rank == 1) {
      return const Text("🥈", style: TextStyle(fontSize: 24));
    }
    if (rank == 2) {
      return const Text("🥉", style: TextStyle(fontSize: 24));
    }
    return Text(
      "${rank + 1}.",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }
}
