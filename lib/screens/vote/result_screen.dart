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
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVoteResults();
  }

  Future<void> fetchVoteResults() async {
    // Ambil semua kandidat
    final candidates = await supabase.from('candidates').select();

    // Ambil semua vote
    final votes = await supabase.from('votes').select();

    // Hitung total vote per kandidat
    Map<String, int> voteCounts = {};

    for (var vote in votes) {
      String candidateId = vote['candidate_id'].toString();
      voteCounts[candidateId] = (voteCounts[candidateId] ?? 0) + 1;
    }

    // Gabungkan data kandidat dan jumlah vote
    List<Map<String, dynamic>> merged = candidates.map((candidate) {
      final id = candidate['candidate_id'].toString();
      return {
        'nama': candidate['nama'],
        'image_url': candidate['image_url'],
        'vote_count': voteCounts[id] ?? 0,
      };
    }).toList();

    // Urutkan dari terbanyak
    merged.sort((a, b) => b['vote_count'].compareTo(a['vote_count']));

    setState(() {
      results = merged;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Voting"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = results[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: item['image_url'] != null && item['image_url'] != ''
                          ? NetworkImage(item['image_url'])
                          : null,
                      child: item['image_url'] == null || item['image_url'] == ''
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(item['nama']),
                    trailing: Text(
                      "${item['vote_count']} suara",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
