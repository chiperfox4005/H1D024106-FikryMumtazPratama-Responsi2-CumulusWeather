import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import 'weather_icon.dart';

class ForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const ForecastCard({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prakiraan Beberapa Hari ke Depan',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navyDark.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppTheme.borderLight,
            ),
            itemBuilder: (context, index) {
              final item = forecasts[index];
              final dayLabel = _formatDayLabel(item.date, index);
              final dateLabel = DateFormat('d MMM', 'id_ID').format(item.date);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayLabel,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WeatherIcon(
                      weatherCode: item.weatherCode,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            size: 14,
                            color: AppTheme.skyBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.precipitationProbability}%',
                            style: const TextStyle(
                              color: AppTheme.skyBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.tempMin.round()}°',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    Text(
                      '${item.tempMax.round()}°',
                      style: const TextStyle(
                        color: AppTheme.navyPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDayLabel(DateTime date, int index) {
    if (index == 0) {
      return 'Hari Ini';
    }
    if (index == 1) {
      return 'Besok';
    }
    return DateFormat('EEEE', 'id_ID').format(date);
  }
}
