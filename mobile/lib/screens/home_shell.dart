import 'package:flutter/material.dart';
import 'live_camera_screen.dart';
import 'my_gallery_screen.dart';
import 'app_settings_screen.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // 2. Ganti LiveCameraScreen(embedded: true) dengan HomeScreen()
  final _screens = const [
    HomeScreen(), // 🟢 SEKARANG JALURNYA BENAR!
    MyGalleryScreen(),
    AppSettingsScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Booth'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'My Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
