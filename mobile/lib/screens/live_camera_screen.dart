import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../utils/booth_draft.dart';
import '../widgets/countdown_overlay.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LiveCameraScreen extends StatefulWidget {
  final bool embedded;
  final int shotCount;
  final String frameId; 

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
  int _selectedCountdown = 3;
  late BoothDraft _draft;

  bool _isReviewingAll = false;
  int? _retakeIndex;

  // === STATE UNTUK MENU LIVE (FILTER, EFFECT, VIBE) ===
  String _selectedFilter = 'Normal';
  String _selectedEffect = 'Normal';
  String _selectedVibe = 'Normal';
  double _vibeIntensity = 0.5;

  // Data matrix filter
  final Map<String, List<double>> _filterMatrices = {
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

  // Data efek
  final _effects = const [
    {'name': 'Normal', 'icon': Icons.circle_outlined},
    {'name': 'Sparkle', 'icon': Icons.auto_awesome},
    {'name': 'Neon Glow', 'icon': Icons.wb_iridescent},
    {'name': 'Dreamy Blur', 'icon': Icons.blur_on},
    {'name': 'Retro Grain', 'icon': Icons.movie_filter},
  ];

  // Dummy Vibe list
  final _vibes = const ['Normal', 'Warm', 'Studio', 'Cinematic'];

  @override
  void initState() {
    super.initState();
    _draft = BoothDraft();
    _draft.frameId = int.tryParse(widget.frameId);
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
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) capturedFile = File(picked.path);
      }

      if (capturedFile != null) {
        setState(() {
          if (_retakeIndex != null) {
            _draft.capturedPhotos[_retakeIndex!] = capturedFile!;
            _retakeIndex = null;
            _isReviewingAll = true;
          } else {
            _draft.capturedPhotos.add(capturedFile!);
            if (_draft.capturedPhotos.length >= widget.shotCount) {
              _isReviewingAll = true; 
            } else {
              _captureWithCountdown();
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
      }
    }
  }

  void _goToNextStep() {
    debugPrint("=== Menuju ke Result/Export ===");
    // Tambahkan navigasi ke layar selanjutnya di sini
  }

  // ================= MENU TAB BOTTOM SHEET =================
  void _openStudioMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DefaultTabController(
              length: 3,
              child: Container(
                height: 300,
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    const TabBar(
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
                        Tab(text: "Filter"),
                        Tab(text: "Effect"),
                        Tab(text: "Vibe"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // TAB 1: FILTER
                          ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            children: ['Normal', ..._filterMatrices.keys].map((name) {
                              final isSelected = _selectedFilter == name;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() => _selectedFilter = name);
                                  setState(() => _selectedFilter = name); 
                                },
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white10,
                                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.primary : Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          // TAB 2: EFFECT
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            itemCount: _effects.length,
                            itemBuilder: (context, i) {
                              final effect = _effects[i];
                              final isSelected = _selectedEffect == effect['name'];
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() => _selectedEffect = effect['name'] as String);
                                  setState(() => _selectedEffect = effect['name'] as String);
                                },
                                child: Container(
                                  width: 90,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white10,
                                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(effect['icon'] as IconData, color: isSelected ? AppColors.primary : Colors.white),
                                      const SizedBox(height: 8),
                                      Text(
                                        effect['name'] as String,
                                        style: TextStyle(color: isSelected ? AppColors.primary : Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // TAB 3: VIBE & LIGHTING
                          Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _vibes.length,
                                  itemBuilder: (context, i) {
                                    final vibe = _vibes[i];
                                    final isSelected = _selectedVibe == vibe;
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() => _selectedVibe = vibe);
                                        setState(() => _selectedVibe = vibe);
                                      },
                                      child: Container(
                                        width: 80,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          vibe,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, color: Colors.white70),
                                    Expanded(
                                      child: Slider(
                                        value: _vibeIntensity,
                                        activeColor: AppColors.primary,
                                        inactiveColor: Colors.white24,
                                        onChanged: (val) {
                                          setModalState(() => _vibeIntensity = val);
                                          setState(() => _vibeIntensity = val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 1. Kamera Preview
            Offstage(
              offstage: _isReviewingAll,
              child: Positioned.fill(child: _buildPreview()),
            ),

            // ==== 2. FRAME OVERLAY (DINAMIS) ====
            if (!_isReviewingAll)
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 2 / 3, 
                    child: IgnorePointer(
                      child: Image.asset(
                        // Mengambil path dinamis berdasarkan frameId yang dipilih user
                        'assets/frames/${widget.frameId}.png', 
                        fit: BoxFit.cover,
                        // Opsional: Error builder jika file frame tidak ditemukan
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white24,
                            child: const Center(child: Text("Frame tidak ditemukan")),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            // ===================================

            // 3. Banner Retake
            if (_retakeIndex != null && !_isReviewingAll)
              Positioned(
                top: 90, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mengambil ulang foto ke-${_retakeIndex! + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => setState(() {
                          _retakeIndex = null;
                          _isReviewingAll = true;
                        }),
                        child: const Text("Batal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      )
                    ],
                  ),
                ),
              ),

            // 4. Header Controls
            if (!_isReviewingAll)
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                          child: Text('${_draft.capturedPhotos.length}/${widget.shotCount} foto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: _switchCamera,
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                              icon: const Icon(Icons.flip_camera_android),
                            ),
                            const SizedBox(width: 8),
                            // Tombol Studio Menu
                            IconButton.filled(
                              onPressed: _openStudioMenu,
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

            // 5. Bottom Shutter Controls
            if (!_isReviewingAll)
              Positioned(
                bottom: 24, left: 0, right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_retakeIndex == null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            const Text("Countdown", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              children: [
                                ChoiceChip(label: const Text("3 s"), selected: _selectedCountdown == 3, onSelected: (b) { if(b) setState(() => _selectedCountdown = 3); }),
                                ChoiceChip(label: const Text("5 s"), selected: _selectedCountdown == 5, onSelected: (b) { if(b) setState(() => _selectedCountdown = 5); }),
                                ChoiceChip(label: const Text("10 s"), selected: _selectedCountdown == 10, onSelected: (b) { if(b) setState(() => _selectedCountdown = 10); }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    GestureDetector(
                      onTap: _showCountdown ? null : _captureWithCountdown,
                      child: Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 6. Countdown Overlay
            if (_showCountdown)
              Positioned.fill(
                child: CountdownOverlay(seconds: _selectedCountdown, onFinished: _onCountdownFinished),
              ),

            // 7. REVIEW GRID
            if (_isReviewingAll)
              Positioned.fill(child: _buildReviewGridOverlay()),
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
              child: Text("Review Hasil Foto", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2 / 3, // Ubah rasio grid review agar sesuai dengan frame
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
                        Positioned(
                          bottom: 8, right: 8,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () async {
                              setState(() {
                                _retakeIndex = index;
                                _isReviewingAll = false; 
                              });
                              await Future.delayed(const Duration(milliseconds: 50));
                              if (_controller != null && _controller!.value.isInitialized) {
                                try { await _controller!.resumePreview(); } catch (_) {}
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(56)),
                child: const Text("Lanjut", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== PENERAPAN FILTER DAN RASIO 2:3 ====
  Widget _buildPreview() {
    if (_controller == null || _initFuture == null) {
      return const Center(child: Text('Kamera tidak terdeteksi.', style: TextStyle(color: Colors.white70)));
    }
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          
          // 1. Dapatkan rasio asli kamera (Pastikan selalu portrait)
          double cameraAspectRatio = _controller!.value.aspectRatio;
          if (cameraAspectRatio > 1.0) cameraAspectRatio = 1.0 / cameraAspectRatio;

          // 2. Terapkan filter jika ada
          Widget cameraWidget = CameraPreview(_controller!);
          if (_selectedFilter != 'Normal' && _filterMatrices.containsKey(_selectedFilter)) {
            cameraWidget = ColorFiltered(
              colorFilter: ColorFilter.matrix(_filterMatrices[_selectedFilter]!),
              child: cameraWidget,
            );
          }

          // 3. Kunci tampilan ke rasio 2:3 dan letakkan di tengah layar
          return Center(
            child: AspectRatio(
              aspectRatio: 2 / 3, // <--- KUNCI RASIO 2:3 DI SINI
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 100, // Angka sembarang, FittedBox akan menyesuaikan proporsinya
                    height: 100 / cameraAspectRatio,
                    child: cameraWidget,
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      },
    );
  }
}