import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/booth_draft.dart';

class ResultScreen extends StatelessWidget {
  final BoothDraft draft;
  const ResultScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Hasil Photostrip")),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 21, // Mengikuti rasio bingkai photostrip
          child: Stack(
            children: [
              // 1. Layer FOTO (Diatur posisinya di belakang lubang frame)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
                  child: Column(
                    children: draft.capturedPhotos.map((file) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            // Pengecekan platform: Gunakan Image.network untuk Web, Image.file untuk Mobile
                            child: kIsWeb
                                ? Image.network(file.path, fit: BoxFit.cover)
                                : Image.file(file, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // 2. Layer FRAME TRANSARAN (Di depan)
              Positioned.fill(
                child: Image.asset(
                  'assets/frames/${draft.frameId}.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}