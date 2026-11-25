import 'dart:convert';
import 'package:cumulus_weather/controllers/location_controller.dart';
import 'package:cumulus_weather/controllers/weather_controller.dart';
import 'package:cumulus_weather/models/location_model.dart';
import 'package:cumulus_weather/models/weather_model.dart';
import 'package:cumulus_weather/services/location_service.dart';
import 'package:cumulus_weather/services/weather_service.dart';
import 'package:cumulus_weather/theme/app_theme.dart';
import 'package:cumulus_weather/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final sampleWeatherJson = {
    'timezone': 'Asia/Jakarta',
    'current': {
      'time': '2026-11-25T12:00',
      'temperature_2m': 31.4,
      'relative_humidity_2m': 68,
      'apparent_temperature': 35.2,
      'precipitation': 0.2,
      'weather_code': 2,
      'wind_speed_10m': 11.5,
    },
    'daily': {
      'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
      'weather_code': [2, 61, 0],
      'temperature_2m_max': [33.0, 30.5, 32.0],
      'temperature_2m_min': [24.0, 23.5, 24.5],
      'precipitation_probability_max': [25, 80, 10],
    },
  };

  final sampleGeocodingJson = {
    'results': [
      {
        'id': 1630328,
        'name': 'Purwokerto',
        'country': 'Indonesia',
        'admin1': 'Jawa Tengah',
        'latitude': -7.42139,
        'longitude': 109.23444,
      },
    ],
  };

  group('Model Tests', () {
    test('WeatherModel.fromJson memetakan data cuaca dan prakiraan harian', () {
      final weather = WeatherModel.fromJson(sampleWeatherJson);

      expect(weather.temperature, 31.4);
      expect(weather.humidity, 68);
      expect(weather.apparentTemperature, 35.2);
      expect(weather.precipitation, 0.2);
      expect(weather.weatherCode, 2);
      expect(weather.windSpeed, 11.5);
      expect(weather.tempMin, 24.0);
      expect(weather.tempMax, 33.0);
      expect(weather.precipitationProbability, 25);
      expect(weather.dailyForecast.length, 3);
      expect(WeatherModel.getConditionName(0), 'Cerah');
      expect(WeatherModel.getConditionName(61), 'Hujan Ringan');
      expect(WeatherModel.getConditionName(95), 'Badai Petir');
    });

    test('LocationModel konversi JSON dan perbandingan lokasi bekerja', () {
      const location = LocationModel(
        id: 1630328,
        name: 'Purwokerto',
        country: 'Indonesia',
        admin1: 'Jawa Tengah',
        latitude: -7.42139,
        longitude: 109.23444,
      );

      final restored = LocationModel.fromJson(location.toJson());
      expect(restored.name, 'Purwokerto');
      expect(restored.subtitle, 'Jawa Tengah, Indonesia');
      expect(restored.isSameAs(location), isTrue);
    });
  });

  group('Service & Controller Tests', () {
    test('WeatherController memuat data cuaca dari WeatherService', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(sampleWeatherJson), 200);
      });

      final controller = WeatherController(
        weatherService: WeatherService(client: mockClient),
      );

      await controller.loadWeather();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.weather, isNotNull);
      expect(controller.weather!.temperature, 31.4);
    });

    test('WeatherController menangani error server dengan pesan jelas', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final controller = WeatherController(
        weatherService: WeatherService(client: mockClient),
      );

      await controller.loadWeather();

      expect(controller.isLoading, isFalse);
      expect(controller.weather, isNull);
      expect(controller.errorMessage, isNotNull);
    });

    test('LocationController menangani pencarian kosong, hasil pencarian, dan favorit', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(sampleGeocodingJson), 200);
      });

      final controller = LocationController(
        locationService: LocationService(client: mockClient),
      );

      await controller.searchCity('   ');
      expect(controller.searchError, isNotNull);
      expect(controller.searchResults, isEmpty);

      await controller.searchCity('Purwokerto');
      expect(controller.searchError, isNull);
      expect(controller.searchResults.length, 1);

      final city = controller.searchResults.first;
      final added = await controller.toggleFavorite(city);
      expect(added, isTrue);
      expect(controller.favorites.length, 1);

      final reloadedController = LocationController(
        locationService: LocationService(client: mockClient),
      );
      await reloadedController.loadFavorites();
      expect(reloadedController.favorites.length, 1);
      expect(reloadedController.favorites.first.name, 'Purwokerto');

      await reloadedController.removeFavorite(city);
      expect(reloadedController.favorites, isEmpty);
    });
  });

  group('Widget Tests', () {
    testWidgets('MainScreen menampilkan cuaca, pencarian kota, dan favorit', (
      WidgetTester tester,
    ) async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('geocoding-api')) {
          return http.Response(jsonEncode(sampleGeocodingJson), 200);
        }
        return http.Response(jsonEncode(sampleWeatherJson), 200);
      });

      final weatherController = WeatherController(
        weatherService: WeatherService(client: mockClient),
      );
      final locationController = LocationController(
        locationService: LocationService(client: mockClient),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MainScreen(
            weatherController: weatherController,
            locationController: locationController,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jakarta'), findsOneWidget);
      expect(find.text('31°C'), findsOneWidget);
      expect(find.text('Berawan Sebagian'), findsOneWidget);
      expect(find.text('Hari Ini'), findsOneWidget);

      await tester.tap(find.text('Cari Kota'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Purwokerto');
      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Purwokerto'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(locationController.favorites.length, 1);

      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();

      expect(find.text('Kota Favorit'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Purwokerto'),
        ),
        findsWidgets,
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Favorit Kosong'), findsOneWidget);
    });
  });
}
