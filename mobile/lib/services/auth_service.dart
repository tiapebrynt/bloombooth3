import 'api_client.dart';
import '../models/user_model.dart';
import '../utils/token_storage.dart';

class AuthService {
  static Future<UserModel> register(String name, String email, String password) async {
    final res = await ApiClient.post(
      '/auth/register',
      {'name': name, 'email': email, 'password': password},
      withAuth: false,
    );
    await TokenStorage.saveToken(res['data']['token']);
    return UserModel.fromJson(res['data']['user']);
  }

  static Future<UserModel> login(String email, String password) async {
    final res = await ApiClient.post(
      '/auth/login',
      {'email': email, 'password': password},
      withAuth: false,
    );
    await TokenStorage.saveToken(res['data']['token']);
    return UserModel.fromJson(res['data']['user']);
  }

  static Future<UserModel> me() async {
    final res = await ApiClient.get('/auth/me');
    return UserModel.fromJson(res['data']);
  }

  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
