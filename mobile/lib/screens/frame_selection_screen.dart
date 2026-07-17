import 'package:flutter/material.dart';
import '../models/frame_model.dart';
import '../services/frame_service.dart';
import '../services/api_client.dart';
import '../utils/theme.dart';
import '../widgets/state_views.dart';
import '../widgets/primary_button.dart';
// UBAH IMPORT: Dari FilterLibraryScreen ke LiveCameraScreen
import 'live_camera_screen.dart'; 
// Tambahkan import ini di bagian atas file:
import '../utils/booth_draft.dart';
class FrameSelectionScreen extends StatefulWidget {
  final BoothDraft draft; // Pastikan draft diterima di sini
  const FrameSelectionScreen({super.key, required this.draft});

  @override
  State<FrameSelectionScreen> createState() => _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends State<FrameSelectionScreen> {
  late Future<List<FrameModel>> _future;
  FrameModel? _selected;

  @override
  void initState() {
    super.initState();
    _future = FrameService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Frame')),
      body: FutureBuilder<List<FrameModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat daftar frame.',
              onRetry: () => setState(() => _future = FrameService.getAll()),
            );
          }
          final frames = snapshot.data ?? [];
          if (frames.isEmpty) return const EmptyView(message: 'Belum ada frame tersedia');
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: frames.length,
                    itemBuilder: (context, i) {
                      final frame = frames[i];
                      final isSelected = frame.id == _selected?.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = frame),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Icon(Icons.filter_frames, size: 48, color: AppColors.secondary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    Text(frame.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(frame.layoutType, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
  label: 'Mulai Kamera',
  onPressed: _selected == null
      ? null
      : () {
          // Pastikan parameter frameId dan shotCount dikirim
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LiveCameraScreen(
                shotCount: 3, // Hardcode sesuai permintaanmu
                frameId: _selected!.id.toString(), // Pastikan dikirim sebagai String
              ),
            ),
          );
        },
),
              ],
            ),
          );
        },
      ),
    );
  }
}