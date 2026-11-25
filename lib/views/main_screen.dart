import 'package:flutter/material.dart';
import '../controllers/location_controller.dart';
import '../controllers/weather_controller.dart';
import '../theme/app_theme.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  final WeatherController? weatherController;
  final LocationController? locationController;

  const MainScreen({
    super.key,
    this.weatherController,
    this.locationController,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final WeatherController _weatherController;
  late final LocationController _locationController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _weatherController = widget.weatherController ?? WeatherController();
    _locationController = widget.locationController ?? LocationController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _locationController.loadFavorites();
    if (_locationController.favorites.isNotEmpty) {
      await _weatherController.loadWeather(
        _locationController.favorites.first,
      );
    } else {
      await _weatherController.loadWeather();
    }
  }

  @override
  void dispose() {
    if (widget.weatherController == null) {
      _weatherController.dispose();
    }
    if (widget.locationController == null) {
      _locationController.dispose();
    }
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              weatherController: _weatherController,
              locationController: _locationController,
              onOpenSearch: () => _switchTab(1),
            ),
            SearchScreen(
              locationController: _locationController,
              weatherController: _weatherController,
              onLocationSelected: () => _switchTab(0),
            ),
            FavoriteScreen(
              locationController: _locationController,
              weatherController: _weatherController,
              onLocationSelected: () => _switchTab(0),
              onOpenSearch: () => _switchTab(1),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny_rounded),
            label: 'Cuaca',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cari Kota',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}
