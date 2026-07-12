import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'home_shell.dart';

/// Splash screen singkat sebelum masuk ke aplikasi. Tidak ada proses
/// login/register di aplikasi ini, jadi langsung diarahkan ke HomeShell.
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
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradient),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_rounded, size: 72, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Photobooth',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
