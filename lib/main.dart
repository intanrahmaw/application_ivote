import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_ivote/splash_screen.dart';
import 'package:application_ivote/splash_screen.dart';
import 'package:application_ivote/welcome1_screen.dart';
import 'package:application_ivote/welcome2_screen.dart';
import 'package:application_ivote/welcome3_screen.dart';
import 'package:application_ivote/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iVote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
