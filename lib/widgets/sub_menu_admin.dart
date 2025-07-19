import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubMenuAdmin {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _BouncyMenuContent();
      },
    );
  }
}

class _BouncyMenuContent extends StatefulWidget {
  const _BouncyMenuContent({super.key});

  @override
  State<_BouncyMenuContent> createState() => _BouncyMenuContentState();
}

class _BouncyMenuContentState extends State<_BouncyMenuContent>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.person,
      'label': 'Manajemen User',
      'subtitle': 'Kelola akun dan akses pengguna',
      'route': '/user'
    },
    {
      'icon': Icons.group,
      'label': 'Manajemen Kandidat',
      'subtitle': 'Atur kandidat pemilu',
      'route': '/candidate'
    },
    {
      'icon': Icons.how_to_vote,
      'label': 'Manajemen Pemilu',
      'subtitle': 'Kelola jadwal dan pengaturan',
      'route': '/election'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _menuItems.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + (index * 100)),
      ),
    );

    _animations = _controllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            ))
        .toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (final controller in _controllers) {
      await Future.delayed(const Duration(milliseconds: 100));
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle Bar
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Menu items
          ...List.generate(_menuItems.length, (index) {
            final item = _menuItems[index];
            return ScaleTransition(
              scale: _animations[index],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(item['route']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(item['icon'], color: Colors.deepPurple, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['label'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['subtitle'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.grey, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
