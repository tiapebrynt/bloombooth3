import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/booth_draft.dart';
import 'home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- Tambah ini

class ResultScreen extends StatelessWidget {
  final BoothDraft draft;
  final String selectedFilter;
  final double filterIntensity;

  const ResultScreen({
    super.key,
    required this.draft,
    required this.selectedFilter,
    required this.filterIntensity,
  });

  // Filter color matrices yang sama dengan FilterScreen
  static const Map<String, List<double>> _filterMatrices = {
    'Retro': [
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Mono (B&W)': [
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Vivid': [
      1.2, 0, 0, 0, 0,
      0, 1.2, 0, 0, 0,
      0, 0, 1.2, 0, 0,
      0, 0, 0, 1, 0,
    ],
    'Cool': [
      0.9, 0, 0, 0, 0,
      0, 0.9, 0, 0, 0,
      0, 0, 1.2, 0, 0,
      0, 0, 0, 1, 0,
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Hasil Photostrip Kamu",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PHOTOSTRIP PREVIEW CONTAINER
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    child: _buildPhotostripCard(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "💡 Tips: Kamu bisa mencubit layar untuk melakukan Zoom pada foto!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 36),

              // TOMBOL AKSI UTAMA
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.save_alt_rounded,
                      label: "Simpan",
                      color: AppColors.primary,
                      onTap: () => _mockAction(context, "Photostrip berhasil disimpan ke galeri!"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.share_rounded,
                      label: "Bagikan",
                      color: Colors.blueAccent,
                      onTap: () => _mockAction(context, "Membuka menu bagikan..."),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                icon: Icons.print_rounded,
                label: "Cetak / Print",
                color: Colors.teal, // FIX: Mengganti Colors.Emerald dengan Colors.teal yang estetik
                onTap: () => _mockAction(context, "Menghubungkan ke printer terdekat..."),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              // KEMBALI KE BERANDA (Back to Home)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text("Kembali ke Beranda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotostripCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: draft.capturedPhotos.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildFilteredImage(draft.capturedPhotos[index]),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.spa, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                "BloomBooth",
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Captured with love",
            style: TextStyle(
              fontSize: 10,
              color: Colors.black38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredImage(File file) {
    final image = kIsWeb
      ? Image.network(file.path, fit: BoxFit.cover)
      : Image.file(file, fit: BoxFit.cover);

  if (selectedFilter == 'Normal' || !_filterMatrices.containsKey(selectedFilter)) {
    return image;
  }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_filterMatrices[selectedFilter]!),
      child: image,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }

  void _mockAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }
} // FIX: Di sini sudah bersih tanpa ada huruf 'r' nyasar di bawahnya!