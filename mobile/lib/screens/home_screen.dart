import 'package:flutter/material.dart';

import '../utils/theme.dart';
import '../utils/booth_draft.dart';      // <-- TAMBAHKAN INI
import 'frame_selection_screen.dart';   // <-- TAMBAHKAN INI

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Icon(
                    Icons.photo_camera_back_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Judul & Subjudul
              const Text(
                "BloomBooth",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Capture your beautiful moments instantly",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 64),

              // Tombol Start
              ElevatedButton(
                // Di HomeScreen.dart
onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      // Langsung ke FrameSelectionScreen
      // FrameSelectionScreen butuh parameter 'draft', kita kirim draft kosong baru
      builder: (_) => FrameSelectionScreen(draft: BoothDraft()),
    ),
  );
},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Start Photobooth",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}