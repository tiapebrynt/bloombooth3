import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart'; // 1. Ubah import ke SplashScreen

void main() {
  runApp(const PhotoboothApp());
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloomBooth', 
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // Tetap gunakan tema bawaan dari utils
      home: const SplashScreen(), // 2. Arahkan ke SplashScreen saat awal dibuka
    );
  }
}