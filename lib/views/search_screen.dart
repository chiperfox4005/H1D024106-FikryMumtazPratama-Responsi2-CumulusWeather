import 'package:flutter/material.dart';
import '../controllers/location_controller.dart';
import '../controllers/weather_controller.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_widget.dart';

class SearchScreen extends StatefulWidget {
  final LocationController locationController;
  final WeatherController weatherController;
  final VoidCallback onLocationSelected;

  const SearchScreen({
    super.key,
    required this.locationController,
    required this.weatherController,
    required this.onLocationSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchInputController = TextEditingController();

  @override
  void dispose() {
    _searchInputController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    widget.locationController.searchCity(_searchInputController.text);
  }

  void _selectLocation(LocationModel location) {
    widget.weatherController.loadWeather(location);
    widget.onLocationSelected();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.locationController,
      builder: (context, _) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      'Cari Lokasi Kota',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Temukan prakiraan cuaca kota di seluruh dunia',
                      style: TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchInputController,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _submitSearch(),
                            decoration: InputDecoration(
                              hintText: 'Contoh: Jakarta, Purwokerto, Tokyo...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.skyBlue,
                              ),
                              suffixIcon: _searchInputController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchInputController.clear();
                                        widget.locationController.clearSearch();
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppTheme.textMuted,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: widget.locationController.isSearching
                                ? null
                                : _submitSearch,
                            child: const Text('Cari'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildResultsArea(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsArea() {
    final controller = widget.locationController;

    if (controller.isSearching) {
      return const LoadingWidget(message: 'Mencari kota...');
    }

    if (controller.searchError != null) {
      return _buildMessageCard(
        icon: Icons.warning_amber_rounded,
        title: 'Pencarian Gagal',
        message: controller.searchError!,
        actionLabel: controller.lastQuery.isNotEmpty ? 'Coba Lagi' : null,
        onAction: controller.lastQuery.isNotEmpty ? _submitSearch : null,
      );
    }

    if (!controller.hasSearched) {
      return _buildMessageCard(
        icon: Icons.travel_explore_rounded,
        title: 'Mulai Pencarian Kota',
        message:
            'Ketik nama kota pada kolom pencarian untuk melihat cuaca dan menambahkannya ke daftar favorit.',
      );
    }

    if (controller.searchResults.isEmpty) {
      return _buildMessageCard(
        icon: Icons.location_off_rounded,
        title: 'Kota Tidak Ditemukan',
        message:
            'Tidak ada hasil untuk "${controller.lastQuery}". Coba periksa ejaan nama kota.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: controller.searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final location = controller.searchResults[index];
        final isFav = controller.isFavorite(location);

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => _selectLocation(location),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.skySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_city_rounded,
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
                final added = await controller.toggleFavorite(location);
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
              tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
              icon: Icon(
                isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFE91E63) : AppTheme.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
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
              Icon(icon, size: 52, color: AppTheme.skyBlue),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 17,
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
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
