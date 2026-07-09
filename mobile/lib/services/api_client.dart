import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await TokenStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _handle(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] ?? 'Terjadi kesalahan tak terduga',
      statusCode: response.statusCode,
    );
  }

  static Future<Map<String, dynamic>> get(String path, {bool withAuth = true}) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(data),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final res = await http.put(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(data),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> delete(String path, {bool withAuth = true}) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handle(res);
  }

  // Upload multipart untuk file foto hasil jepretan Live Camera / stiker custom
  static Future<Map<String, dynamic>> uploadImage(String path, String filePath) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handle(response);
  }
}
