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
  bool _showCountdown = false;
  String _selectedLiveEffect = 'Normal';
  late BoothDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = BoothDraft();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(front, ResolutionPreset.high, enableAudio: false);
      _initFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      // Kamera tidak tersedia (mis. saat dijalankan di emulator tanpa kamera virtual)
      debugPrint('Kamera tidak tersedia: $e');
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
      body: Stack(
        children: [
          Positioned.fill(child: _buildPreview()),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_draft.capturedPhotos.length}/${_draft.requiredShotCount} foto',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _openLiveEffects,
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Shutter button
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showCountdown ? null : _captureWithCountdown,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
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
            ),
          ),

          if (_showCountdown)
            CountdownOverlay(seconds: 3, onFinished: _onCountdownFinished),
        ],
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
          return CameraPreview(_controller!);
        }
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      },
    );
  }
}
