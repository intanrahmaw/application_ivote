import 'package:flutter/material.dart';
// Pastikan path ke global_user.dart sudah benar
import 'package:application_ivote/utils/global_user.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisikan item navigasi berdasarkan peran pengguna (role)
    // Desain di Figma paling cocok dengan tampilan admin
    List<_NavItem> navItems = [];

    if (loggedInUserRole == 'admin') {
      navItems = [
        _NavItem(
          activeIcon: Icons.home,
          inactiveIcon: Icons.home_outlined,
          label: 'Home',
        ),
        _NavItem(
          activeIcon: Icons.settings,
          inactiveIcon: Icons.settings_outlined,
          label: 'Pengaturan',
        ),
        _NavItem(
          activeIcon: Icons.bar_chart,
          inactiveIcon: Icons.bar_chart_outlined,
          label: 'Hasil Vote',
        ),
        _NavItem(
          activeIcon: Icons.person,
          inactiveIcon: Icons.person_outline,
          label: 'Profile',
        ),
      ];
    } else {
      // Tampilan untuk 'user' biasa, bisa disesuaikan juga
      navItems = [
        _NavItem(
          activeIcon: Icons.home,
          inactiveIcon: Icons.home_outlined,
          label: 'Home',
        ),
        _NavItem(
          activeIcon: Icons.how_to_vote,
          inactiveIcon: Icons.how_to_vote_outlined,
          label: 'Vote',
        ),
        _NavItem(
          activeIcon: Icons.bar_chart,
          inactiveIcon: Icons.bar_chart_outlined,
          label: 'Hasil Vote',
        ),
        _NavItem(
          activeIcon: Icons.person,
          inactiveIcon: Icons.person_outline,
          label: 'Profile',
        ),
      ];
    }

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final navItem = navItems[index];
            final isSelected = index == selectedIndex;
            final color = isSelected ? Colors.black : Colors.grey.shade500;

            return Expanded(
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                // Membuat area tap transparan
                behavior: HitTestBehavior.translucent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? navItem.activeIcon : navItem.inactiveIcon,
                      color: color,
                      size: 26,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      navItem.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Modifikasi class _NavItem untuk menampung dua jenis ikon
class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
