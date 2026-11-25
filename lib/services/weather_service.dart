import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  Future<List<LocationModel>> searchCity(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'id',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Gagal mencari kota (${res.statusCode})');
    }
    final json = jsonDecode(res.body);
    final results = json['results'] as List?;
    if (results == null) return [];
    return results.map((e) => LocationModel.fromJson(e)).toList();
  }

  Future<WeatherData> getWeather(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current':
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil cuaca (${res.statusCode})');
    }
    return WeatherData.fromJson(jsonDecode(res.body));
  }
}