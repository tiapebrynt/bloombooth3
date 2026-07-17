import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart'; // 1. Tambahkan import HomeScreen

void main() {
  runApp(const PhotoboothApp());
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobooth App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(), // 2. Ganti dari SplashScreen ke HomeScreen
    );
  }
}