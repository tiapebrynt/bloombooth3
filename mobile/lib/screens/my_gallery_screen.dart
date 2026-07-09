import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_session_model.dart';
import '../services/session_service.dart';
import '../services/api_client.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/state_views.dart';
import 'strip_detail_screen.dart';

class MyGalleryScreen extends StatefulWidget {
  const MyGalleryScreen({super.key});

  @override
  State<MyGalleryScreen> createState() => _MyGalleryScreenState();
}

class _MyGalleryScreenState extends State<MyGalleryScreen> {
  late Future<List<PhotoSessionModel>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = SessionService.getAll();
  }

  Future<void> _refresh() async {
    setState(() => _future = SessionService.getAll());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('My Gallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Cari strip...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<PhotoSessionModel>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingView();
                    }
                    if (snapshot.hasError) {
                      return ErrorView(
                        message: snapshot.error is ApiException
                            ? (snapshot.error as ApiException).message
                            : 'Gagal memuat galeri. Periksa koneksi ke backend.',
                        onRetry: _refresh,
                      );
                    }
                    var sessions = snapshot.data ?? [];
                    if (_query.isNotEmpty) {
                      sessions = sessions
                          .where((s) => s.title.toLowerCase().contains(_query))
                          .toList();
                    }
                    if (sessions.isEmpty) {
                      return const EmptyView(message: 'Belum ada strip tersimpan.\nYuk mulai photobooth!');
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: sessions.length,
                      itemBuilder: (context, i) {
                        final session = sessions[i];
                        return _GalleryCard(
                          session: session,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StripDetailScreen(sessionId: session.id),
                              ),
                            );
                            _refresh();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final PhotoSessionModel session;
  final VoidCallback onTap;
  const _GalleryCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbUrl = session.frameThumbnail != null
        ? '${AppConstants.storageUrl}${session.frameThumbnail}'
        : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: thumbUrl != null
                    ? Image.network(
                        thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(session.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.secondary.withOpacity(0.15),
        child: const Center(child: Icon(Icons.photo, color: AppColors.secondary, size: 40)),
      );
}

String _formatDate(String raw) {
  try {
    final date = DateTime.parse(raw);
    return DateFormat('d MMM yyyy').format(date);
  } catch (_) {
    return raw.split(' ').first;
  }
}
