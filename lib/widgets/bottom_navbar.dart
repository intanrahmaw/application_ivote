import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepPurple, // Warna ikon/label aktif
      unselectedItemColor: Colors.grey,     // Warna ikon/label tidak aktif
      type: BottomNavigationBarType.fixed, // Agar semua item terlihat
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart), // Asumsi ikon ini untuk Hasil Vote
          label: 'Hasil Vote',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}