import 'package:flutter/material.dart';

class CustomBottomNavBarAdmin extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBarAdmin({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    List<NavItemData> items = [
      NavItemData(Icons.home, 'Home'),
      NavItemData(Icons.settings, 'Settings'),
      NavItemData(Icons.bar_chart, 'Hasil Vote'),
      NavItemData(Icons.person, 'Profil'),
    ];

    return Material(
      elevation: 10,
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              final item = items[index];

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.deepPurple.withOpacity(0.2),
                  onTap: () => onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            item.icon,
                            color: isSelected ? Colors.deepPurple : Colors.grey,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final String label;

  NavItemData(this.icon, this.label);
}
