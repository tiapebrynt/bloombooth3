import 'package:flutter/material.dart';
import '../utils/booth_draft.dart';
import '../utils/theme.dart';
import '../widgets/primary_button.dart';
import 'final_preview_screen.dart';

class BeautyEnhancementScreen extends StatefulWidget {
  final BoothDraft draft;
  const BeautyEnhancementScreen({super.key, required this.draft});

  @override
  State<BeautyEnhancementScreen> createState() => _BeautyEnhancementScreenState();
}

class _BeautyEnhancementScreenState extends State<BeautyEnhancementScreen> {
  late double _smooth;
  late double _brighten;
  bool _naturalGlow = true;

  @override
  void initState() {
    super.initState();
    _smooth = widget.draft.beautySmooth;
    _brighten = widget.draft.beautyBrighten;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beauty Enhancement')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              value: _naturalGlow,
              onChanged: (v) => setState(() => _naturalGlow = v),
              title: const Text('Natural Glow'),
              subtitle: const Text('Efek beauty otomatis dengan hasil natural'),
              activeColor: AppColors.primary,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            const SizedBox(height: 20),
            const Text('Smooth Skin', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _smooth,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _smooth = v),
            ),
            const SizedBox(height: 12),
            const Text('Face Brighten', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _brighten,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _brighten = v),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Lihat Final Preview',
              onPressed: () {
                widget.draft.beautySmooth = _smooth;
                widget.draft.beautyBrighten = _brighten;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FinalPreviewScreen(draft: widget.draft)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
