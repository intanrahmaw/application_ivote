import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/screens/splash_screen.dart';
import 'package:application_ivote/screens/welcome/welcome1_screen.dart';
import 'package:application_ivote/screens/welcome/welcome2_screen.dart';
import 'package:application_ivote/screens/welcome/welcome3_screen.dart';
import 'package:application_ivote/screens/auth/register_screen.dart';
import 'package:application_ivote/screens/home/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'iVote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
