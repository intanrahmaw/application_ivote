// lib/utils/app_routes.dart

import 'package:get/get.dart';
import 'package:application_ivote/screens/edit_profil_screen.dart';
import 'package:application_ivote/screens/logout_screen.dart'; 

class AppRoutes {
  static const String edit_profil_screen = '/edit_profil_screen';
  static const String logout_screen = '/logout_screen';

  static final routes = [
    GetPage(name: edit_profil_screen, page: () => const EditProfileScreen()),
    GetPage(name: logout_screen, page: () => const LogoutScreen()),
  ];
}