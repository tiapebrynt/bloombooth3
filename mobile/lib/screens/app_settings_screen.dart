import 'package:flutter/material.dart';
import '../models/app_settings_model.dart';
import '../models/user_model.dart';
import '../services/settings_service.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';
import '../utils/theme.dart';
import '../widgets/state_views.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late Future<_SettingsBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SettingsBundle> _load() async {
    final user = await ProfileService.get();
    final settings = await SettingsService.get();
    return _SettingsBundle(user, settings);
  }

  Future<void> _updateSettings(AppSettingsModel settings) async {
    try {
      final updated = await SettingsService.update(settings);
      setState(() {
        _future = _future.then((bundle) => _SettingsBundle(bundle.user, updated));
      });
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _renameProfile(UserModel user) async {
    final controller = TextEditingController(text: user.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      try {
        final updated = await ProfileService.update(name: newName);
        setState(() {
          _future = _future.then((bundle) => _SettingsBundle(updated, bundle.settings));
        });
      } on ApiException catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_SettingsBundle>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat pengaturan.',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final user = snapshot.data!.user;
          final settings = snapshot.data!.settings;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('App Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
                      onPressed: () => _renameProfile(user),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Preferensi Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Resolusi Kamera'),
                      trailing: DropdownButton<String>(
                        value: settings.cameraResolution,
                        underline: const SizedBox(),
                        items: const ['720p', '1080p', '4K']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          _updateSettings(AppSettingsModel(
                            id: settings.id,
                            userId: settings.userId,
                            cameraResolution: v,
                            watermarkEnabled: settings.watermarkEnabled,
                            countdownDuration: settings.countdownDuration,
                            liveEffectsEnabled: settings.liveEffectsEnabled,
                          ));
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Durasi Countdown'),
                      subtitle: Text('${settings.countdownDuration} detik'),
                      trailing: SizedBox(
                        width: 140,
                        child: Slider(
                          value: settings.countdownDuration.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: AppColors.primary,
                          onChanged: (v) => _updateSettings(AppSettingsModel(
                            id: settings.id,
                            userId: settings.userId,
                            cameraResolution: settings.cameraResolution,
                            watermarkEnabled: settings.watermarkEnabled,
                            countdownDuration: v.round(),
                            liveEffectsEnabled: settings.liveEffectsEnabled,
                          )),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Watermark'),
                      value: settings.watermarkEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _updateSettings(AppSettingsModel(
                        id: settings.id,
                        userId: settings.userId,
                        cameraResolution: settings.cameraResolution,
                        watermarkEnabled: v,
                        countdownDuration: settings.countdownDuration,
                        liveEffectsEnabled: settings.liveEffectsEnabled,
                      )),
                    ),
                    SwitchListTile(
                      title: const Text('Live Effects'),
                      value: settings.liveEffectsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _updateSettings(AppSettingsModel(
                        id: settings.id,
                        userId: settings.userId,
                        cameraResolution: settings.cameraResolution,
                        watermarkEnabled: settings.watermarkEnabled,
                        countdownDuration: settings.countdownDuration,
                        liveEffectsEnabled: v,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsBundle {
  final UserModel user;
  final AppSettingsModel settings;
  _SettingsBundle(this.user, this.settings);
}
