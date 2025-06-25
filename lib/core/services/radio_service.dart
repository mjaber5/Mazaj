import 'package:dio/dio.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class RadioService {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://mazaj.me/api'));

  Future<List<RadioItem>> getRadioList() async {
    try {
      final response = await dio.get('/radios');
      final data = response.data;

      // ✅ Access the "radios" key safely
      final List<dynamic> radiosJson = data['radios'];

      return radiosJson.map((item) => RadioItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load radios: $e');
    }
  }
}
