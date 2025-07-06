import 'package:application_ivote/screens/hasil_voting_screen.dart';
import 'package:application_ivote/screens/profile/profile_screen.dart';
import 'package:application_ivote/widgets/custom_bottom_nav_bar_user.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iVote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProfileScreen(),
    );
  }
}
