import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_user.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_admin.dart';
import 'package:application_ivote/utils/global_user.dart';
import 'package:application_ivote/screens/vote/vote_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (loggedInUserRole == 'admin') {
      switch (index) {
        case 0:
          // Tetap di Dashboard
          break;
        case 1:
          _showSettingsMenu();
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
          // Tetap di Dashboard
          break;
        case 1:
          Get.off(const VoteScreen());
          break;
        case 2:
      Get.toNamed('/user/hasil-vote'); // atau panggil widget hasil vote langsung
      break;
    case 3:
      Get.toNamed('/profile'); // atau Get.off(const ProfileScreen());
      break;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/admin/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Kandidat'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/admin/kandidat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_vote),
              title: const Text('Election'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/admin/election');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading jika belum login
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
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
            _buildKandidatCard('Intan Rahma', 'Kandidat 1'),
            const SizedBox(height: 16.0),
            _buildKandidatCard('Fadenta', 'Kandidat 2'),
          ],
        ),
      ),
      bottomNavigationBar: loggedInUserRole == 'admin'
          ? CustomBottomNavBarAdmin(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : CustomBottomNavBarUser(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
    );
  }

  Widget _buildTimerCard() {
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
              Text(
                'Waktu tersisa untuk pemilu',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeItem('100', 'Hari'),
              _buildTimeItem('5', 'Jam'),
              _buildTimeItem('19', 'Menit'),
              _buildTimeItem('47', 'Detik'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: const [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'cari kandidat...',
                border: InputBorder.none,
              ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
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
            child: const Text(
              'lihat profile',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}