import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  final WeatherService _weatherService;

  static const LocationModel defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    country: 'Indonesia',
    admin1: 'Jakarta',
    latitude: -6.21462,
    longitude: 106.84513,
  );

  WeatherModel? _weather;
  LocationModel _selectedLocation = defaultLocation;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherController({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  WeatherModel? get weather => _weather;
  LocationModel get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWeather([LocationModel? location]) async {
    if (location != null) {
      _selectedLocation = location;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );
      _weather = result;
    } catch (e) {
      _errorMessage = _formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    await loadWeather(_selectedLocation);
  }

  String _formatError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    return text;
  }
}
