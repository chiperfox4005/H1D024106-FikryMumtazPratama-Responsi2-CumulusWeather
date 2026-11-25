import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController extends ChangeNotifier {
  final LocationService _locationService;

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  bool _isSearching = false;
  bool _isLoadingFavorites = false;
  bool _hasSearched = false;
  String? _searchError;
  String? _favoriteError;
  String _lastQuery = '';

  LocationController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  bool get isSearching => _isSearching;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get hasSearched => _hasSearched;
  String? get searchError => _searchError;
  String? get favoriteError => _favoriteError;
  String get lastQuery => _lastQuery;

  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      _searchError = 'Masukkan nama kota terlebih dahulu.';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _locationService.searchLocations(trimmed);
    } catch (e) {
      _searchResults = [];
      _searchError = _formatError(e);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _hasSearched = false;
    _searchError = null;
    _lastQuery = '';
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    _favoriteError = null;
    notifyListeners();

    try {
      _favorites = await _locationService.getFavorites();
    } catch (e) {
      _favoriteError = 'Gagal memuat daftar lokasi favorit.';
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item.isSameAs(location));
  }

  Future<void> addFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      return;
    }
    _favorites = [..._favorites, location];
    notifyListeners();
    await _persistFavorites();
  }

  Future<void> removeFavorite(LocationModel location) async {
    _favorites = _favorites.where((item) => !item.isSameAs(location)).toList();
    notifyListeners();
    await _persistFavorites();
  }

  Future<bool> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      await removeFavorite(location);
      return false;
    } else {
      await addFavorite(location);
      return true;
    }
  }

  Future<void> _persistFavorites() async {
    try {
      await _locationService.saveFavorites(_favorites);
      _favoriteError = null;
    } catch (e) {
      _favoriteError = 'Gagal menyimpan perubahan favorit.';
      notifyListeners();
    }
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
