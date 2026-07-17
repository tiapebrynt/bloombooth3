import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../utils/booth_draft.dart';
import '../widgets/countdown_overlay.dart';
import 'live_effects_screen.dart';
import 'filter_library_screen.dart'; // Navigasi tujuan berikutnya
import 'package:flutter/foundation.dart' show kIsWeb;

class LiveCameraScreen extends StatefulWidget {
  final bool embedded;
  final int shotCount;
  final String frameId; // Menerima ID frame pilihan user dari layar sebelumnya

  const LiveCameraScreen({
    super.key,
    this.embedded = false,
    required this.shotCount,
    required this.frameId,
  });

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
  late BoothDraft _draft;

  // State untuk Alur Review & Retake
  bool _isReviewingAll = false;
  int? _retakeIndex;

  @override
  void initState() {
    super.initState();
    _draft = BoothDraft();
    _draft.frameId = int.tryParse(widget.frameId); // Simpan frame terpilih ke dalam draft
    _initCamera();
    debugPrint("=== LiveCameraScreen Diinisialisasi (Frame ID: ${widget.frameId}) ===");
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
      debugPrint('Kamera tidak tersedia: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initFuture = _controller!.initialize();
    if (mounted) setState(() {});
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
      File? capturedFile;
      if (_controller != null && _controller!.value.isInitialized) {
        final file = await _controller!.takePicture();
        capturedFile = File(file.path);
      } else {
        // Fallback emulator/browser jika tanpa kamera fisik
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) {
          capturedFile = File(picked.path);
        }
      }

      if (capturedFile != null) {
        setState(() {
          if (_retakeIndex != null) {
            // MODE RETAKE: Ganti foto lama di indeks terpilih
            _draft.capturedPhotos[_retakeIndex!] = capturedFile!;
            _retakeIndex = null;
            _isReviewingAll = true; // Kembali ke Grid Review
          } else {
            // MODE NORMAL: Tambahkan foto baru
            _draft.capturedPhotos.add(capturedFile!);

            // Batasan foto dinamis sesuai parameter widget.shotCount (biasanya di-lock 3)
            if (_draft.capturedPhotos.length >= widget.shotCount) {
              _isReviewingAll = true; 
            } else {
              _captureWithCountdown(); // Otomatis lanjut countdown foto berikutnya
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  // Alur lanjut ke FilterLibraryScreen dengan membawa draf foto & frame
  void _goToNextStep() {
    debugPrint("=== Menuju ke FilterLibraryScreen ===");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilterLibraryScreen(draft: _draft),
      ),
    );
  }

  Future<void> _openLiveEffects() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => LiveEffectsScreen(current: _selectedLiveEffect)),
    );
    if (selected != null) setState(() => _selectedLiveEffect = selected);
  }

  // JALUR RETAKE MOBILE: Mengaktifkan ulang kamera
  Future<void> _startRetakeMobile(int index) async {
    setState(() {
      _retakeIndex = index;
      _isReviewingAll = false;
    });

    await Future.delayed(const Duration(milliseconds: 150));

    if (_controller != null && _controller!.value.isInitialized) {
      try {
        await _controller!.resumePreview();
      } catch (_) {
        try {
          await _controller!.initialize();
        } catch (_) {}
      }
    }
    _captureWithCountdown();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build berjalan. _isReviewingAll = $_isReviewingAll");

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 1. Kamera Preview — Menggunakan Offstage agar elemen <video> di Web tidak dispose
            Offstage(
              offstage: _isReviewingAll,
              child: Positioned.fill(child: _buildPreview()),
            ),

            // 2. Banner Retake (Hanya di HP/Mobile saat countdown retake aktif)
            if (_retakeIndex != null && !_isReviewingAll)
              Positioned(
                top: 90,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mengambil ulang foto ke-${_retakeIndex! + 1}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _retakeIndex = null;
                            _isReviewingAll = true;
                          });
                        },
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            // 3. Header Controls
            if (!_isReviewingAll)
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_draft.capturedPhotos.length}/${widget.shotCount} foto',
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
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                              icon: const Icon(Icons.flip_camera_android),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _openLiveEffects,
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                              icon: const Icon(Icons.auto_awesome),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 4. Bottom Shutter Controls
            if (!_isReviewingAll)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_retakeIndex == null)
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              children: [
                                ChoiceChip(
                                  label: const Text("3 s"),
                                  selected: _selectedCountdown == 3,
                                  onSelected: (bool selected) {
                                    if (selected) setState(() => _selectedCountdown = 3);
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text("5 s"),
                                  selected: _selectedCountdown == 5,
                                  onSelected: (bool selected) {
                                    if (selected) setState(() => _selectedCountdown = 5);
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text("10 s"),
                                  selected: _selectedCountdown == 10,
                                  onSelected: (bool selected) {
                                    if (selected) setState(() => _selectedCountdown = 10);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    GestureDetector(
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
                  ],
                ),
              ),

            // 5. Countdown Overlay
            if (_showCountdown)
              Positioned.fill(
                child: CountdownOverlay(
                  seconds: _selectedCountdown,
                  onFinished: _onCountdownFinished,
                ),
              ),

            // 6. REVIEW GRID (Murni dipisahkan dengan layout rapi)
            if (_isReviewingAll)
              Positioned.fill(
                child: _buildReviewGridOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewGridOverlay() {
    return Container(
      color: Colors.grey.shade900,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Review Hasil Foto",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Grid Foto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: _draft.capturedPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(_draft.capturedPhotos[index].path, fit: BoxFit.cover)
                                : Image.file(_draft.capturedPhotos[index], fit: BoxFit.cover),
                          ),
                        ),
                        
                        // Tombol Retake (Dipastikan tidak menempel ke area luar)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () async {
  debugPrint("Tombol Retake di indeks $index diklik!");
  setState(() {
    _retakeIndex = index;
    _isReviewingAll = false; // ini yang bikin Offstage jadi false lagi
  });

  // beri 1 frame supaya widget preview kembali "onstage" dulu
  await Future.delayed(const Duration(milliseconds: 50));

  if (_controller != null && _controller!.value.isInitialized) {
    try {
      await _controller!.resumePreview();
    } catch (e) {
      debugPrint('resumePreview gagal/tidak didukung: $e');
    }
  }
  _captureWithCountdown();
},
                            child: const Text("Retake", style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Tombol Lanjut
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Tombol Lanjut diklik!");
                  _goToNextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text("Lanjut ke Filter", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tambahkan fungsi pembantu agar logic Retake Web lebih bersih
  Future<void> _handleWebRetake(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() => _draft.capturedPhotos[index] = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Gagal retake web: $e");
    }
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
              double cameraAspectRatio = _controller!.value.aspectRatio;
              
              final isPortrait = constraints.maxHeight > constraints.maxWidth;
              if (isPortrait && cameraAspectRatio > 1.0) {
                cameraAspectRatio = 1.0 / cameraAspectRatio;
              }

              double width = constraints.maxWidth;
              double height = constraints.maxWidth / cameraAspectRatio;

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