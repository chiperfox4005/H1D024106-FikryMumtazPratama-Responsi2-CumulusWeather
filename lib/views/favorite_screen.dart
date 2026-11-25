import 'package:flutter/material.dart';
import '../controllers/location_controller.dart';
import '../controllers/weather_controller.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_widget.dart';

class FavoriteScreen extends StatelessWidget {
  final LocationController locationController;
  final WeatherController weatherController;
  final VoidCallback onLocationSelected;
  final VoidCallback onOpenSearch;

  const FavoriteScreen({
    super.key,
    required this.locationController,
    required this.weatherController,
    required this.onLocationSelected,
    required this.onOpenSearch,
  });

  void _selectFavorite(LocationModel location) {
    weatherController.loadWeather(location);
    onLocationSelected();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locationController,
      builder: (context, _) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kota Favorit',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Akses cepat lokasi pilihan Anda',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: onOpenSearch,
                          tooltip: 'Tambah Kota',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppTheme.white.withValues(alpha: 0.16),
                          ),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildContent(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (locationController.isLoadingFavorites) {
      return const LoadingWidget(message: 'Memuat daftar favorit...');
    }

    if (locationController.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navyDark.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 56,
                  color: AppTheme.skyBlue,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Daftar Favorit Kosong',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan kota favorit dari halaman Beranda atau Cari Kota agar mudah diakses kembali.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onOpenSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Cari Kota'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: locationController.favorites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final location = locationController.favorites[index];
        final isSelected =
            weatherController.selectedLocation.isSameAs(location);

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isSelected
                ? const BorderSide(color: AppTheme.skyBlue, width: 1.6)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => _selectFavorite(location),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.skySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppTheme.skyBlue,
              ),
            ),
            title: Text(
              location.name,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location.subtitle.isNotEmpty)
                  Text(
                    location.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () async {
                await locationController.removeFavorite(location);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${location.name} dihapus dari daftar favorit',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              tooltip: 'Hapus favorit',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        );
      },
    );
  }
}
