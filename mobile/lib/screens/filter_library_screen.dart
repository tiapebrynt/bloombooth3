import 'package:flutter/material.dart';
import '../models/filter_model.dart';
import '../services/filter_service.dart';
import '../services/api_client.dart';
import '../utils/booth_draft.dart';
import '../utils/theme.dart';
import '../widgets/state_views.dart';
import '../widgets/primary_button.dart';
import 'vibe_lighting_screen.dart';

class FilterLibraryScreen extends StatefulWidget {
  final BoothDraft draft;
  const FilterLibraryScreen({super.key, required this.draft});

  @override
  State<FilterLibraryScreen> createState() => _FilterLibraryScreenState();
}

class _FilterLibraryScreenState extends State<FilterLibraryScreen> {
  late Future<List<FilterModel>> _future;
  FilterModel? _selected;

  @override
  void initState() {
    super.initState();
    _future = FilterService.getAll(type: 'color');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Library')),
      body: FutureBuilder<List<FilterModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat daftar filter.',
              onRetry: () => setState(() => _future = FilterService.getAll(type: 'color')),
            );
          }
          final filters = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: filters.isEmpty
                      ? const EmptyView(message: 'Belum ada filter tersedia')
                      : ListView.separated(
                          itemCount: filters.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final filter = filters[i];
                            final isSelected = filter.id == _selected?.id;
                            return ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary.withOpacity(0.15),
                                child: const Icon(Icons.color_lens, color: AppColors.secondary),
                              ),
                              title: Text(filter.name),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                                  : null,
                              onTap: () => setState(() => _selected = filter),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Lanjut ke Vibe Lighting',
                  onPressed: () {
                    widget.draft.colorFilterId = _selected?.id;
                    widget.draft.colorFilterName = _selected?.name;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VibeLightingScreen(draft: widget.draft),
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
