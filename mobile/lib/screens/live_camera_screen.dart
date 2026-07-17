import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../utils/booth_draft.dart';
import '../widgets/countdown_overlay.dart';
import 'live_effects_screen.dart';
import 'frame_selection_screen.dart';

/// Layar "Live Camera": preview kamera real-time, tombol jepret dengan
/// countdown, dan akses ke "Live Effects" untuk preview filter real-time.
/// [embedded] = true saat dipakai sebagai tab pertama BottomNavigationBar.
class LiveCameraScreen extends StatefulWidget {
  final bool embedded;
  const LiveCameraScreen({super.key, this.embedded = false});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _showCountdown = false;
  String _selectedLiveEffect = 'Normal';
  int _selectedCountdown = 3;

int _selectedLayout = 4;

bool _isFrontCamera = true;
  late BoothDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = BoothDraft();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
    _cameras = await availableCameras();
      _controller = CameraController(
  _cameras[_cameraIndex],
  ResolutionPreset.high,
  enableAudio: false,
);
      _initFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      // Kamera tidak tersedia (mis. saat dijalankan di emulator tanpa kamera virtual)
      debugPrint('Kamera tidak tersedia: $e');
    }
  }

  Future<void> _switchCamera() async {
  if (_cameras.length < 2) return;

  _cameraIndex =
      (_cameraIndex + 1) % _cameras.length;

  await _controller?.dispose();

  _controller = CameraController(
    _cameras[_cameraIndex],
    ResolutionPreset.high,
    enableAudio: false,
  );

  _initFuture = _controller!.initialize();

  if (mounted) {
    setState(() {});
  }
}

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureWithCountdown() async {
    setState(() => _showCountdown = true);
  }

  Future<void> _onCountdownFinished() async {
    setState(() => _showCountdown = false);
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final file = await _controller!.takePicture();
        _draft.capturedPhotos.add(File(file.path));
      } else {
        // Fallback: emulator tanpa kamera -> ambil dari galeri agar alur tetap bisa didemokan
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) _draft.capturedPhotos.add(File(picked.path));
      }
      setState(() {});
      if (_draft.capturedPhotos.length >= _draft.requiredShotCount) {
        _goToFrameSelection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  void _goToFrameSelection() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => FrameSelectionScreen(draft: _draft)))
        .then((_) => setState(() => _draft = BoothDraft()));
  }

  Future<void> _openLiveEffects() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => LiveEffectsScreen(current: _selectedLiveEffect)),
    );
    if (selected != null) setState(() => _selectedLiveEffect = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 1. Paksa body untuk memenuhi seluruh space yang tersedia
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Kamera sekarang menjadi penentu utama atau mengikuti size full screen
            Positioned.fill(child: _buildPreview()),

            // 2. Ubah Header menjadi Positioned di paling atas agar tidak merusak tinggi Stack
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_draft.capturedPhotos.length}/${_draft.requiredShotCount} foto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: _switchCamera,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black45,
                            ),
                            icon: const Icon(Icons.flip_camera_android),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _openLiveEffects,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black45,
                            ),
                            icon: const Icon(Icons.auto_awesome),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Bottom Controls (Tetap Positioned, sekarang posisinya akan akurat di bawah)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ================= TIMER =================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Countdown",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              label: const Text("3 s"),
                              selected: _selectedCountdown == 3,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCountdown = 3;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text("5 s"),
                              selected: _selectedCountdown == 5,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCountdown = 5;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text("10 s"),
                              selected: _selectedCountdown == 10,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCountdown = 10;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ================= SHUTTER =================
                  GestureDetector(
                    onTap: _showCountdown ? null : _captureWithCountdown,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showCountdown)
              Positioned.fill(
                child: CountdownOverlay(
                  seconds: _selectedCountdown,
                  onFinished: _onCountdownFinished,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_controller == null || _initFuture == null) {
      return const Center(
        child: Text(
          'Kamera tidak terdeteksi.\nGunakan device fisik untuk preview live camera.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Ambil aspect ratio asli dari controller kamera
              final cameraAspectRatio = _controller!.value.aspectRatio;

              // Lakukan kalkulasi BoxFit.cover secara manual agar aman di Web & Mobile
              double width = constraints.maxWidth;
              double height = constraints.maxWidth / cameraAspectRatio;

              // Jika tinggi hasil kalkulasi masih kurang memenuhi layar, balik rumusnya
              if (height < constraints.maxHeight) {
                height = constraints.maxHeight;
                width = constraints.maxHeight * cameraAspectRatio;
              }

              return ClipRect(
                child: OverflowBox(
                  maxWidth: width,
                  maxHeight: height,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: CameraPreview(_controller!),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      },
    );
  }
}
