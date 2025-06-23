import 'package:flutter/material.dart';

class Welcome3Screen extends StatelessWidget {
  const Welcome3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Digunakan untuk perhitungan ukuran gambar agar tetap responsif terhadap lebar layar,
    // yang membantu mempertahankan tampilan yang sama di berbagai ukuran perangkat.
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Mengamankan konten dari tumpang tindih dengan bilah status (status bar)
        child: SingleChildScrollView( // Memungkinkan konten untuk digulir jika melebihi tinggi layar, mencegah overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Tambahkan navigasi ke layar selanjutnya atau lewati welcome screen
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),

                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: screenWidth * 0.4,
                      height: screenWidth * 0.4,
                      child: Image.asset(
                        'assets/Image/welcome3.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),

                const Text(
                  'Make your choice',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),

                const Text(
                  'Vote for your favorite candidate,\nand view the results in real time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 70.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indikator 1 (Sekarang Tidak Aktif)
                    Container(
                      width: 8.0, // Diubah dari 24.0
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Diubah dari Colors.black
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),

                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Abu-abu lebih terang untuk tidak aktif
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Indikator 2 (Sekarang Aktif)
                    Container(
                      width: 24.0, // Diubah dari 8.0
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.black, // Diubah dari Colors.grey[300]
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                const SizedBox(height: 50.0),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      //welcome
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}