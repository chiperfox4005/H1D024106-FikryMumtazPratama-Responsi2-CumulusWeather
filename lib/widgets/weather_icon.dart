import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final int weatherCode;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.weatherCode,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(weatherCode),
      size: size,
      color: color ?? _getDefaultColor(weatherCode),
    );
  }

  static IconData _getIconData(int code) {
    if (code == 0) {
      return Icons.wb_sunny_rounded;
    }
    if (code == 1 || code == 2) {
      return Icons.wb_cloudy_rounded;
    }
    if (code == 3) {
      return Icons.cloud_rounded;
    }
    if (code == 45 || code == 48) {
      return Icons.foggy;
    }
    if (code >= 51 && code <= 57) {
      return Icons.grain_rounded;
    }
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.umbrella_rounded;
    }
    if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 95) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.cloud_queue_rounded;
  }

  static Color _getDefaultColor(int code) {
    if (code == 0) {
      return const Color(0xFFFFB300);
    }
    if (code == 1 || code == 2) {
      return const Color(0xFF38BDF8);
    }
    if (code == 3 || code == 45 || code == 48) {
      return const Color(0xFF90A4AE);
    }
    if (code >= 95) {
      return const Color(0xFF5C6BC0);
    }
    return const Color(0xFF2196F3);
  }
}
