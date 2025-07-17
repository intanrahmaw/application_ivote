import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_user.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_admin.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/screens/vote/vote_screen.dart';
import 'package:application_ivote/widgets/sub_menu_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
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
    final response = await supabase.from('kandidat').select();
    setState(() {
      kandidatList = List<Map<String, dynamic>>.from(response);
    });
  }

  void _fetchElectionEndTime() async {
    final response = await supabase
        .from('elections')
        .select('end_time')
        .order('end_time', ascending: false)
        .limit(1)
        .single();

    if (response['end_time'] != null) {
      setState(() {
        endTime = DateTime.parse(response['end_time']);
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        remainingTime = endTime!.difference(now).isNegative
            ? Duration.zero
            : endTime!.difference(now);
      });
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          break;
        case 1:
          DashboardAdminMenu.show(context);
          return;
        case 2:
          Get.toNamed('/admin/hasil-vote');
          return;
        case 3:
          Get.toNamed('/admin/profil');
          return;
      }
    } else {
      switch (index) {
        case 0:
          break;
        case 1:
          Get.off(const VoteScreen());
          break;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUserRole.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          ' ${loggedInUserName.isNotEmpty ? loggedInUserName.capitalizeFirst! : 'Pengguna'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerCard(),
            const SizedBox(height: 24.0),
            const Text('Kandidat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            ...kandidatList.map((k) => Column(
              children: [
                _buildKandidatCard(k['nama_kandidat'], k['label_kandidat']),
                const SizedBox(height: 16.0),
              ],
            )),
          ],
        ),
      ),
      bottomNavigationBar: loggedInUserRole == 'admin'
          ? CustomBottomNavBarAdmin(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped)
          : CustomBottomNavBarUser(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
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
              Text('Waktu tersisa untuk pemilu',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        children: const [
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'cari kandidat...', border: InputBorder.none),
            ),
          ),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildKandidatCard(String name, String role) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('lihat profile', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
