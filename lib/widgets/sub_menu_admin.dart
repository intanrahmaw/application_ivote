// lib/screens/home/dashboard_admin_menu.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/utils/app_routes.dart';

class DashboardAdminMenu {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // ⬅️ Tambahkan ini
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
              title: const Text('User'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Kandidat'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/kandidat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_vote),
              title: const Text('Election'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/election');
              },
            ),
          ],
        );
      },
    );
  }
}