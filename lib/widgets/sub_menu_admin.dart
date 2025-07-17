import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardAdminMenu {
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
    {'icon': Icons.person, 'label': 'User', 'route': '/user'},
    {'icon': Icons.group, 'label': 'Kandidat', 'route': '/candidate'},
    {'icon': Icons.how_to_vote, 'label': 'Election', 'route': '/election'},
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
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          ...List.generate(_menuItems.length, (index) {
            final item = _menuItems[index];
            return ScaleTransition(
              scale: _animations[index],
              child: ListTile(
                leading: Icon(item['icon'], color: Colors.deepPurple),
                title: Text(
                  item['label'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(item['route']);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hoverColor: Colors.deepPurple.withOpacity(0.05),
                splashColor: Colors.deepPurple.withOpacity(0.1),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
