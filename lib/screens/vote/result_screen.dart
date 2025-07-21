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
  List<Map<String, dynamic>> groupedResults = [];
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    fetchVoteResults();
  }

  Future<void> fetchVoteResults() async {
    try {
      final candidates = await supabase
          .from('candidates')
          .select('*, elections!inner(is_active)')
          .eq('elections.is_active', true);

      if (candidates.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final candidateIds = candidates.map((c) => c['candidate_id']).toList();

      final votes = await supabase
          .from('votes')
          .select()
          .inFilter('candidate_id', candidateIds);

      // Hitung total suara untuk kandidat di election aktif saja
      Map<String, int> voteCounts = {};
      for (var vote in votes) {
        final cid = vote['candidate_id'].toString();
        voteCounts[cid] = (voteCounts[cid] ?? 0) + 1;
      }

      // Total semua suara dari election aktif
      int allVotes = voteCounts.values.fold(0, (a, b) => a + b);
      totalVotes = allVotes;

      // Kelompokkan berdasarkan organisasi
      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var candidate in candidates) {
        final org = candidate['organisasi'] ?? 'Lainnya';
        final cid = candidate['candidate_id'].toString();
        final count = voteCounts[cid] ?? 0;

        candidate['vote_count'] = count;
        grouped.putIfAbsent(org, () => []).add(candidate);
      }

      if (mounted) {
        setState(() {
          groupedResults = grouped.entries.map((e) {
          return {
            'organisasi': e.key,
            'candidates': e.value,
            'total_votes': e.value.fold<int>(0, (sum, c) => sum + ((c['vote_count'] as int?) ?? 0)),
          };
        }).toList();
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
        title: const Text(
          "Hasil Voting",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    if (groupedResults.isEmpty) {
      return const Center(child: Text("Belum ada hasil voting"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildTotalVotesCard();

        final orgData = groupedResults[index - 1];
        return _buildOrganizationSection(orgData);
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

  Widget _buildOrganizationSection(Map<String, dynamic> orgData) {
    final String org = orgData['organisasi'];
    final List candidates = orgData['candidates'];
    final int orgTotalVotes = orgData['total_votes'];

    candidates.sort((a, b) => (b['vote_count'] as int).compareTo(a['vote_count'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          org,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          candidates.length,
          (i) => _buildResultCard(candidates[i], i, orgTotalVotes),
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item, int rank, int orgTotalVotes) {
    final vote = item['vote_count'] as int;
    final percent = orgTotalVotes == 0 ? 0.0 : vote / orgTotalVotes;
    final imageUrl = item['image_url'] ?? '';
    final nama = item['nama'] ?? 'Nama Kandidat';

    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildRankIcon(rank),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  backgroundColor: Colors.grey[200],
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
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
            LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              color: Colors.purple,
              backgroundColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$vote suara",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank == 0) return const Text("🥇", style: TextStyle(fontSize: 24));
    if (rank == 1) return const Text("🥈", style: TextStyle(fontSize: 24));
    if (rank == 2) return const Text("🥉", style: TextStyle(fontSize: 24));
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
