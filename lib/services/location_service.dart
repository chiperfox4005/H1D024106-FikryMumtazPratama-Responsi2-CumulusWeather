import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocationService {
  static const String _favoritesKey = 'favorite_locations';
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': trimmedQuery,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mencari lokasi (kode ${response.statusCode}).',
        );
      }

      if (response.body.isEmpty) {
        return [];
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic>? results = data['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        return [];
      }

      return results
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Batas waktu koneksi habis saat mencari kota.');
    } on http.ClientException {
      throw Exception(
        'Tidak ada koneksi internet. Gagal menghubungi layanan pencarian kota.',
      );
    } on FormatException {
      throw Exception('Gagal memproses hasil pencarian kota.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan saat mencari kota.');
    }
  }

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> storedList = prefs.getStringList(_favoritesKey) ?? [];
    return storedList
        .map(
          (item) =>
              LocationModel.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList = favorites
        .map((location) => jsonEncode(location.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, encodedList);
  }
}
