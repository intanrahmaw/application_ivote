// lib/utils/app_routes.dart

import 'package:get/get.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/dashboard_screen.dart';
import '../../screens/welcome/welcome1_screen.dart';
import '../../screens/welcome/welcome2_screen.dart';
import '../../screens/welcome/welcome3_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/settings/users/user_management_screen.dart';
import '../../screens/settings/elections/election_management_screen.dart';
import '../../screens/settings/candidates/candidate_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/vote/vote_screen.dart';
import '../../screens/vote/vote_succes_screen.dart';
import '../../screens/vote/result_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome1 = '/welcome1';
  static const String welcome2 = '/welcome2';
  static const String welcome3 = '/welcome3';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String user = '/user';
  static const String election = '/election';
  static const String candidate = '/candidate';
  static const String profile = '/profile';
  static const String vote = '/vote';
  static const String votesucces = '/votesucces';
  static const String result = '/result';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome1, page: () => const Welcome1Screen()),
    GetPage(name: welcome2, page: () => const Welcome2Screen()),
    GetPage(name: welcome3, page: () => const Welcome3Screen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: user, page: () => const UserManagementScreen()),
    GetPage(name: election, page: () => const ElectionManagementScreen()),
    GetPage(name: candidate, page: () => const CandidatListScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: vote, page: () => const VoteScreen()),
    GetPage(name: votesucces, page: () => const VoteSuccessScreen()),
    GetPage(name: result, page: () => const VoteResultScreen()),
  ];
}
