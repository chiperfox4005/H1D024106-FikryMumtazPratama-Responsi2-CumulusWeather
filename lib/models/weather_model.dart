class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int precipitationProbability;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbability,
  });
}

class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final DateTime currentTime;
  final String timezone;
  final double tempMin;
  final double tempMax;
  final int precipitationProbability;
  final List<DailyForecast> dailyForecast;

  const WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.currentTime,
    required this.timezone,
    required this.tempMin,
    required this.tempMax,
    required this.precipitationProbability,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final times = (daily['time'] as List<dynamic>?) ?? [];
    final codes = (daily['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>?) ?? [];
    final rainProbs =
        (daily['precipitation_probability_max'] as List<dynamic>?) ?? [];

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecast(
          date: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
          weatherCode: i < codes.length ? (codes[i] as num).toInt() : 0,
          tempMax: i < maxTemps.length
              ? (maxTemps[i] as num).toDouble()
              : 0.0,
          tempMin: i < minTemps.length
              ? (minTemps[i] as num).toDouble()
              : 0.0,
          precipitationProbability:
              i < rainProbs.length && rainProbs[i] != null
              ? (rainProbs[i] as num).toInt()
              : 0,
        ),
      );
    }

    final double todayMin = forecasts.isNotEmpty
        ? forecasts.first.tempMin
        : (current['temperature_2m'] as num).toDouble();
    final double todayMax = forecasts.isNotEmpty
        ? forecasts.first.tempMax
        : (current['temperature_2m'] as num).toDouble();
    final int todayRainProb = forecasts.isNotEmpty
        ? forecasts.first.precipitationProbability
        : 0;

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      currentTime:
          DateTime.tryParse((current['time'] as String?) ?? '') ??
          DateTime.now(),
      timezone: (json['timezone'] as String?) ?? 'auto',
      tempMin: todayMin,
      tempMax: todayMax,
      precipitationProbability: todayRainProb,
      dailyForecast: forecasts,
    );
  }

  static String getConditionName(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Hujan Salju';
      case 80:
        return 'Hujan Lokal Ringan';
      case 81:
        return 'Hujan Lokal Sedang';
      case 82:
        return 'Hujan Lokal Deras';
      case 85:
      case 86:
        return 'Badai Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Hujan Es';
      default:
        return 'Berawan';
    }
  }
}
