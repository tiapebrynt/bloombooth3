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
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _frames.length,
        itemBuilder: (ctx, i) {
          final id = _frames[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedId = id),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: _selectedId == id ? Colors.blue : Colors.grey)),
              child: Image.asset('assets/frames/$id.png', fit: BoxFit.cover),
            ),
          );
        },
      ),
      floatingActionButton: _selectedId == null ? null : FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => LiveCameraScreen(shotCount: 3, frameId: _selectedId.toString()),
        )),
        child: const Icon(Icons.check),
      ),
    );
  }
}