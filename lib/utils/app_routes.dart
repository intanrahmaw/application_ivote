// lib/utils/app_routes.dart

import 'package:application_ivote/screens/profile/profile_screen.dart';
import 'package:get/get.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/welcome/welcome1_screen.dart';
import '../../screens/welcome/welcome2_screen.dart';
import '../../screens/welcome/welcome3_screen.dart';
import '../../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome1 = '/welcome1';
  static const String welcome2 = '/welcome2';
  static const String welcome3 = '/welcome3';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome1, page: () => const Welcome1Screen()),
    GetPage(name: welcome2, page: () => const Welcome2Screen()),
    GetPage(name: welcome3, page: () => const Welcome3Screen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
  ];
}
