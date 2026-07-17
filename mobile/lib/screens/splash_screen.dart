import 'package:flutter/material.dart';
import '../utils/theme.dart'; 
import 'home_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHome();
  }

  Future<void> _goToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengunci warna pilihanmu: RGB(255, 111, 145)
    const customPink = Color.fromARGB(255, 255, 111, 145);

    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Teks BloomBooth (Bold & Warna Custom Pink)
            const Text(
              'BloomBooth',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold, // Efek Bold pada teks
                letterSpacing: 2.0,
                color: customPink, 
              ),
            ),
            const SizedBox(height: 32),
            
            // 2. Animasi Loading Garis (LinearProgressIndicator)
            SizedBox(
              width: 150, // Mengatur panjang garis loading agar tidak memenuhi layar
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Membuat ujung garis agak membulat rapi
                child: const LinearProgressIndicator(
                  minHeight: 6, // Mengatur ketebalan garis ("Bold")
                  backgroundColor: Color.fromARGB(50, 255, 111, 145), // Latar belakang garis versi agak transparan
                  valueColor: AlwaysStoppedAnimation<Color>(customPink), // Warna utama garis jalan
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}