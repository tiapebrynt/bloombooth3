class AppConstants {
  // Ganti sesuai environment:
  // - Emulator Android      -> http://10.0.2.2:3000/api
  // - Device fisik (WiFi)   -> http://<IP-LAPTOP-KAMU>:3000/api
  // - Backend online/hosted -> https://domain-kamu.com/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Base URL tanpa /api, dipakai untuk load gambar dari /uploads
  static const String storageUrl = 'http://10.0.2.2:3000';
}
