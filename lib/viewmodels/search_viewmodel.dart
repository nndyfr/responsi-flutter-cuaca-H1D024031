import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import 'view_state.dart';

class SearchViewModel extends ChangeNotifier {
  final WeatherService _service;
  final StorageService _storage;

  SearchViewModel(this._service, this._storage);

  List<LocationModel> results = [];
  List<LocationModel> favorites = [];
  ViewState state = ViewState.idle;
  String errorMessage = '';

  Future<void> loadFavorites() async {
    favorites = await _storage.loadFavorites();
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    state = ViewState.loading;
    notifyListeners();
    try {
      results = await _service.searchCity(query.trim());
      state = results.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      errorMessage = 'Gagal mencari kota. Periksa koneksi internet.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  bool isFavorite(LocationModel loc) => favorites.contains(loc);

  Future<void> toggleFavorite(LocationModel loc) async {
    if (isFavorite(loc)) {
      favorites.remove(loc);
    } else {
      favorites.add(loc);
    }
    await _storage.saveFavorites(favorites);
    notifyListeners();
  }
}