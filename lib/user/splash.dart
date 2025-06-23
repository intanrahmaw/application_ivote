import 'package:flutter/material.dart';
import 'dart:async';

import 'package:application_ivote/user/welcome1_screen.dart';



class SplashScreenUser extends StatefulWidget {
  const SplashScreenUser({super.key});

  @override
  State<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends State<SplashScreenUser> {
  @override
  void initState() {
    super.initState();
    // Delay 3 detik lalu pindah ke halaman berikutnya
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Welcome1Screen()),
      );
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Bisa kamu ganti sesuai tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
             'image/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              'i-Vote App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}