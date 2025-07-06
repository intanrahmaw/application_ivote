import 'package:flutter/material.dart';

class HasilVotingScreen extends StatelessWidget {
  const HasilVotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            _buildTotalSuaraCard(),
            const SizedBox(height: 24),
            _buildResultCard(name: 'Intan Rahma', percentage: 58, votes: 540, color: Colors.deepPurple),
            const SizedBox(height: 16),
            _buildResultCard(name: 'Fadenta', percentage: 42, votes: 340, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSuaraCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Total suara masuk', style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 8),
          Text('1.000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultCard({required String name, required int percentage, required int votes, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$percentage%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Votes: $votes', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}