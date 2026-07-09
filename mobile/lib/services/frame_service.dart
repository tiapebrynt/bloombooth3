import 'api_client.dart';
import '../models/frame_model.dart';

class FrameService {
  static Future<List<FrameModel>> getAll() async {
    final res = await ApiClient.get('/frames');
    return (res['data'] as List).map((e) => FrameModel.fromJson(e)).toList();
  }

  static Future<FrameModel> getOne(int id) async {
    final res = await ApiClient.get('/frames/$id');
    return FrameModel.fromJson(res['data']);
  }

  static Future<FrameModel> create(FrameModel frame) async {
    final res = await ApiClient.post('/frames', frame.toJson());
    return FrameModel.fromJson(res['data']);
  }

  static Future<FrameModel> update(int id, FrameModel frame) async {
    final res = await ApiClient.put('/frames/$id', frame.toJson());
    return FrameModel.fromJson(res['data']);
  }

  static Future<void> remove(int id) async {
    await ApiClient.delete('/frames/$id');
  }
}
