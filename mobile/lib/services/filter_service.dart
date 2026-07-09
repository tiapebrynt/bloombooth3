import 'api_client.dart';
import '../models/filter_model.dart';

class FilterService {
  static Future<List<FilterModel>> getAll({String? type}) async {
    final query = type != null ? '?type=$type' : '';
    final res = await ApiClient.get('/filters$query');
    return (res['data'] as List).map((e) => FilterModel.fromJson(e)).toList();
  }

  static Future<FilterModel> create(FilterModel filter) async {
    final res = await ApiClient.post('/filters', filter.toJson());
    return FilterModel.fromJson(res['data']);
  }

  static Future<FilterModel> update(int id, FilterModel filter) async {
    final res = await ApiClient.put('/filters/$id', filter.toJson());
    return FilterModel.fromJson(res['data']);
  }

  static Future<void> remove(int id) async {
    await ApiClient.delete('/filters/$id');
  }
}
