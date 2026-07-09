import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}
