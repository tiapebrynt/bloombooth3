import 'api_client.dart';
import '../models/decoration_model.dart';

class DecorationService {
  static Future<DecorationModel> update(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.put('/decorations/$id', data);
    return DecorationModel.fromJson(res['data']);
  }

  static Future<void> remove(int id) async {
    await ApiClient.delete('/decorations/$id');
  }
}
