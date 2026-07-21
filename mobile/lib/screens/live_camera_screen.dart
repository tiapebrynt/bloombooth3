import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../utils/booth_draft.dart';
import '../widgets/countdown_overlay.dart';
import 'result_screen.dart';
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

  String _selectedFilter = 'Normal';
  String _selectedEffect = 'Normal';
  String _selectedVibe = 'Normal';
  double _vibeIntensity = 0.5;

  final Map<String, List<double>> _filterMatrices = {
    'Retro': [0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0],
    'Mono (B&W)': [0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0],
    'Vivid': [1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0],
    'Cool': [0.9, 0, 0, 0, 0, 0, 0.9, 0, 0, 0, 0, 0, 1.2, 0, 0, 0, 0, 0, 1, 0],
  };

  final _effects = const [
    {'name': 'Normal', 'icon': Icons.circle_outlined},
    {'name': 'Sparkle', 'icon': Icons.auto_awesome},
    {'name': 'Neon Glow', 'icon': Icons.wb_iridescent},
    {'name': 'Dreamy Blur', 'icon': Icons.blur_on},
    {'name': 'Retro Grain', 'icon': Icons.movie_filter},
  ];

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
      _controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.high, enableAudio: false);
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
    _controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.high, enableAudio: false);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(draft: _draft),
      ),
    );
  }

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
                      tabs: [Tab(text: "Filter"), Tab(text: "Effect"), Tab(text: "Vibe")],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
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
                                  child: Text(name, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white)),
                                ),
                              );
                            }).toList(),
                          ),
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            itemCount: _effects.length,
                            itemBuilder: (context, i) {
                              final effect = _effects[i];
                              return GestureDetector(
                                onTap: () => setModalState(() => _selectedEffect = effect['name'] as String),
                                child: Container(
                                  width: 90,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(effect['icon'] as IconData, color: Colors.white),
                                      Text(effect['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _vibes.length,
                                  itemBuilder: (context, i) {
                                    return Container(
                                      width: 80, margin: const EdgeInsets.only(right: 12),
                                      alignment: Alignment.center,
                                      child: Text(_vibes[i], style: const TextStyle(color: Colors.white)),
                                    );
                                  },
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
            Offstage(
              offstage: _isReviewingAll,
              child: Positioned.fill(child: _buildPreview()),
            ),
            if (_isReviewingAll)
              Positioned.fill(child: _buildReviewGridOverlay()),
            if (!_isReviewingAll)
              Positioned(
                bottom: 24, left: 0, right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _showCountdown ? null : _captureWithCountdown,
                      child: Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                        child: Container(margin: const EdgeInsets.all(6), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            if (_showCountdown)
              Positioned.fill(
                child: CountdownOverlay(seconds: _selectedCountdown, onFinished: _onCountdownFinished),
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
              child: Text("Review Hasil Foto", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, 
                    childAspectRatio: 3 / 2, // <--- UBAH KE 3:2 DI SINI
                  ),
                  itemCount: _draft.capturedPhotos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_draft.capturedPhotos[index].path, fit: BoxFit.cover)
                          : Image.file(_draft.capturedPhotos[index], fit: BoxFit.cover),
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
                child: const Text("Lanjut ke Frame", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==== PREVIEW KAMERA DENGAN RASIO 3:2 ====
  Widget _buildPreview() {
    if (_controller == null || _initFuture == null) {
      return const Center(child: Text('Kamera tidak terdeteksi.', style: TextStyle(color: Colors.white70)));
    }
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Widget cameraWidget = CameraPreview(_controller!);

          if (_selectedFilter != 'Normal' && _filterMatrices.containsKey(_selectedFilter)) {
            cameraWidget = ColorFiltered(
              colorFilter: ColorFilter.matrix(_filterMatrices[_selectedFilter]!),
              child: cameraWidget,
            );
          }

          return Center(
            child: AspectRatio(
              aspectRatio: 3 / 2, // <--- RASIO 3:2 LANDSCAPE
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.previewSize?.height ?? 100,
                    height: _controller!.value.previewSize?.width ?? 100,
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