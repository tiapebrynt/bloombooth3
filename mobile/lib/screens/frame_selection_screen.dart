import 'package:flutter/material.dart';
import '../utils/booth_draft.dart';
import 'live_camera_screen.dart';

class FrameSelectionScreen extends StatefulWidget {
  final BoothDraft draft;
  const FrameSelectionScreen({super.key, required this.draft});

  @override
  State<FrameSelectionScreen> createState() => _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends State<FrameSelectionScreen> {
  // Gabungan 9-14 dan 19-24
  final List<int> _frames = [9, 10, 11, 12, 13, 14, 19, 20, 21, 22, 23, 24];
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Frame")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,     // 1. Ubah ke 2 kolom agar frame lebih jelas & tidak kekecilan
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.45, // 2. Rasio pas (tidak terlalu tinggi/jangkung)
        ),
        itemCount: _frames.length,
        itemBuilder: (ctx, i) {
          final id = _frames[i];
          final isSelected = _selectedId == id;

          return GestureDetector(
            onTap: () => setState(() => _selectedId = id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: isSelected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // 3. ClipRRect + BoxFit.cover membuat frame MEMENUHI KARTU tanpa celah kosong
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  'assets/frames/$id.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _selectedId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveCameraScreen(
                    shotCount: 3,
                    frameId: _selectedId.toString(),
                  ),
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text("Gunakan Frame"),
            ),
    );
  }
}