import 'package:application_ivote/user/login.dart';
import 'package:application_ivote/user/splash.dart';
import 'package:flutter/material.dart';
import 'package:application_ivote/user/welcome1_screen.dart';
import 'package:application_ivote/user/welcome2_screen.dart';
import 'package:application_ivote/user/welcome3_screen.dart';

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
      home: LoginScreen(),
    );
  }
}
