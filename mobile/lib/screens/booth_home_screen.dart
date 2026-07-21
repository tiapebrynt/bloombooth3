import 'package:flutter/material.dart';
import '../utils/booth_draft.dart';
import '../utils/theme.dart';
import '../widgets/primary_button.dart';
import 'frame_selection_screen.dart';

/// Home tab: titik awal alur photobooth.
/// Dari sini user menekan "Start Photobooth" -> pilih frame -> live camera.
class BoothHomeScreen extends StatelessWidget {
  const BoothHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Photobooth',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ambil foto strip favoritmu dengan filter, effect, dan vibe kece.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Start Photobooth',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    // Draft baru setiap kali mulai sesi baru
                    final draft = BoothDraft();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FrameSelectionScreen(draft: draft)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}