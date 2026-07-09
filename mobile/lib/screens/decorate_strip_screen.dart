import 'package:flutter/material.dart';
import '../models/photo_session_model.dart';
import '../models/decoration_model.dart';
import '../services/session_service.dart';
import '../services/decoration_service.dart';
import '../services/api_client.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/state_views.dart';

const _quickEmojis = ['😍', '🎉', '✨', '💕', '🔥', '😂', '👏', '🥳'];

class DecorateStripScreen extends StatefulWidget {
  final int sessionId;
  const DecorateStripScreen({super.key, required this.sessionId});

  @override
  State<DecorateStripScreen> createState() => _DecorateStripScreenState();
}

class _DecorateStripScreenState extends State<DecorateStripScreen> {
  late Future<PhotoSessionModel> _future;
  List<DecorationModel> _decorations = [];
  String? _bgImage;

  @override
  void initState() {
    super.initState();
    _future = SessionService.getOne(widget.sessionId).then((session) {
      _decorations = List.from(session.decorations);
      _bgImage = session.photos.isNotEmpty ? session.photos.first.imagePath : null;
      return session;
    });
  }

  Future<void> _addEmoji(String emoji) async {
    Navigator.pop(context); // close bottom sheet
    try {
      final created = await SessionService.addDecoration(
        widget.sessionId,
        DecorationModel(
          id: 0,
          sessionId: widget.sessionId,
          type: 'emoji',
          content: emoji,
          posX: 120,
          posY: 200,
        ),
      );
      setState(() => _decorations.add(created));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _addText() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Teks'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Contoh: Best Day Ever!')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Tambah')),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    try {
      final created = await SessionService.addDecoration(
        widget.sessionId,
        DecorationModel(
          id: 0,
          sessionId: widget.sessionId,
          type: 'text',
          content: text,
          posX: 80,
          posY: 260,
        ),
      );
      setState(() => _decorations.add(created));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Emoji', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _quickEmojis
                    .map((e) => GestureDetector(
                          onTap: () => _addEmoji(e),
                          child: Text(e, style: const TextStyle(fontSize: 28)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _addText();
                },
                icon: const Icon(Icons.text_fields),
                label: const Text('Tambah Teks'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePosition(DecorationModel deco, Offset newPos) async {
    setState(() {
      final idx = _decorations.indexWhere((d) => d.id == deco.id);
      _decorations[idx] = DecorationModel(
        id: deco.id,
        sessionId: deco.sessionId,
        type: deco.type,
        content: deco.content,
        posX: newPos.dx,
        posY: newPos.dy,
        scale: deco.scale,
        rotation: deco.rotation,
      );
    });
  }

  Future<void> _persistPosition(DecorationModel deco) async {
    try {
      await DecorationService.update(deco.id, {'pos_x': deco.posX, 'pos_y': deco.posY});
    } on ApiException catch (_) {
      // gagal sync posisi, biarkan tersimpan lokal & bisa dicoba lagi
    }
  }

  Future<void> _deleteDecoration(DecorationModel deco) async {
    try {
      await DecorationService.remove(deco.id);
      setState(() => _decorations.removeWhere((d) => d.id == deco.id));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decorate Strip')),
      body: FutureBuilder<PhotoSessionModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat strip untuk didekorasi.',
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (_bgImage != null)
                          Positioned.fill(
                            child: Image.network(
                              '${AppConstants.storageUrl}$_bgImage',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.background),
                            ),
                          ),
                        for (final deco in _decorations)
                          Positioned(
                            left: deco.posX,
                            top: deco.posY,
                            child: GestureDetector(
                              onPanUpdate: (details) => _updatePosition(
                                deco,
                                Offset(deco.posX + details.delta.dx, deco.posY + details.delta.dy),
                              ),
                              onPanEnd: (_) => _persistPosition(deco),
                              onLongPress: () => _deleteDecoration(deco),
                              child: deco.type == 'text'
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        deco.content,
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Text(deco.content, style: const TextStyle(fontSize: 36)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Geser untuk memindahkan • Tekan lama untuk menghapus',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_reaction_outlined, color: Colors.white),
      ),
    );
  }
}
