import 'package:flutter/material.dart';
import '../controllers/location_controller.dart';
import '../controllers/weather_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/forecast_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_details.dart';

class HomeScreen extends StatelessWidget {
  final WeatherController weatherController;
  final LocationController locationController;
  final VoidCallback onOpenSearch;

  const HomeScreen({
    super.key,
    required this.weatherController,
    required this.locationController,
    required this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([weatherController, locationController]),
      builder: (context, _) {
        return SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_rounded,
              color: AppTheme.skyLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cumulus Weather',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Informasi & Prakiraan Cuaca',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenSearch,
            tooltip: 'Cari Kota',
            icon: const Icon(Icons.search_rounded, color: AppTheme.white),
          ),
          IconButton(
            onPressed: weatherController.isLoading
                ? null
                : () => weatherController.refreshWeather(),
            tooltip: 'Perbarui Cuaca',
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (weatherController.isLoading && weatherController.weather == null) {
      return const LoadingWidget(message: 'Mengambil data cuaca...');
    }

    if (weatherController.errorMessage != null &&
        weatherController.weather == null) {
      return _buildErrorState(context, weatherController.errorMessage!);
    }

    final weather = weatherController.weather;
    if (weather == null) {
      return _buildEmptyState(context);
    }

    final location = weatherController.selectedLocation;
    final isFav = locationController.isFavorite(location);

    return RefreshIndicator(
      color: AppTheme.skyBlue,
      onRefresh: weatherController.refreshWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (weatherController.errorMessage != null)
                  _buildInlineErrorBanner(weatherController.errorMessage!),
                if (weatherController.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      color: AppTheme.skyLight,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                WeatherCard(
                  location: location,
                  weather: weather,
                  isFavorite: isFav,
                  onToggleFavorite: () async {
                    final added =
                        await locationController.toggleFavorite(location);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? '${location.name} ditambahkan ke favorit'
                                : '${location.name} dihapus dari favorit',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                WeatherDetails(weather: weather),
                const SizedBox(height: 20),
                if (weather.dailyForecast.isNotEmpty)
                  ForecastCard(forecasts: weather.dailyForecast),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC62828)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: AppTheme.skyBlue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Cuaca',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => weatherController.refreshWeather(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_queue_rounded,
                size: 56,
                color: AppTheme.skyBlue,
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada data cuaca',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => weatherController.refreshWeather(),
                child: const Text('Muat Cuaca'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
