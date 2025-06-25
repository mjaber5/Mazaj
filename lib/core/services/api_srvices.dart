import 'package:dio/dio.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';

class ApiService {
  static const String baseUrl = 'https://mazaj.me/api/radios';
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<List<RadioStation>> fetchRadios({
    String? country,
    String? genres,
    String? search,
    bool featured = false,
    String? id,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;
      if (genres != null) queryParams['genres'] = genres;
      if (search != null) queryParams['search'] = search;
      if (featured) queryParams['featured'] = '1';
      if (id != null) queryParams['id'] = id;
      if (groupBy != null) queryParams['group_by'] = groupBy;

      final response = await _dio.get(baseUrl, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        final List radios = data['radios'];
        return radios.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load radios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching radios: $e');
    }
  }
}
