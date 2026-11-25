import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import 'weather_icon.dart';

class WeatherCard extends StatelessWidget {
  final LocationModel location;
  final WeatherModel weather;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const WeatherCard({
    super.key,
    required this.location,
    required this.weather,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE, d MMMM yyyy • HH:mm',
      'id_ID',
    ).format(weather.currentTime);
    final conditionName = WeatherModel.getConditionName(weather.weatherCode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDark.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.skyLight,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (location.country.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          location.subtitle,
                          style: TextStyle(
                            color: AppTheme.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambah ke favorit',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.white.withValues(alpha: 0.16),
                ),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFFFF6B8B) : AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formattedDate,
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°C',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conditionName,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terasa seperti ${weather.apparentTemperature.round()}°C',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: WeatherIcon(
                  weatherCode: weather.weatherCode,
                  size: 64,
                  color: weather.weatherCode == 0
                      ? const Color(0xFFFFD54F)
                      : AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TempSummaryItem(
                  label: 'Suhu Min',
                  value: '${weather.tempMin.round()}°C',
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: AppTheme.white.withValues(alpha: 0.3),
                ),
                _TempSummaryItem(
                  label: 'Suhu Maks',
                  value: '${weather.tempMax.round()}°C',
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: AppTheme.white.withValues(alpha: 0.3),
                ),
                _TempSummaryItem(
                  label: 'Peluang Hujan',
                  value: '${weather.precipitationProbability}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TempSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _TempSummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.78),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
